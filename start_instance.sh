#!/bin/bash
set -eu

# check if the instance-id(argument) is given
: $1 $2 $3 $4

# logging
function log() {
	: $1 $2
	local level=$1
	local msg=$2
	if [ ${level} == "ERROR" ]; then
		echo "[$(date +'%Y/%m/%d %T%:z')]${level} ${msg}" 1>&2
	else
		echo "[$(date +'%Y/%m/%d %T%:z')]${level} ${msg}"
	fi
}

# get status of target instance
function get_instance_state() {
	local instance_id=$1
	local status=` \
		aws ec2 describe-instance-status \
        		--include-all-instances \
        		--instance-ids "${instance_id}" \
        	| jq '.InstanceStatuses[0].InstanceState.Name' \
        	| tr -d '"'`
	
	# exit if failed to get instance status
	if [ -z ${status} ]; then
		log ERROR "failed to get status"
		exit 1
	else
		log INFO "current instance status: ${status}"
	fi
}

# execute main procedure
instance_id=$1
private_key=$2
user_name=$3
host_name=$4
status=`get_instance_state $1 | awk '{ print $NF }'`

case ${status} in
	"pending" )
		log INFO "${instance_id} is now starting. wait a minute and retry."
		sleep 60
		bash $0 $1
		;;
	"running" )
		log INFO "connect to ${instance_id}..."
		if [ `ps aux | grep 18080:localhost:8080 | wc -l` -gt 1 ]; then
			log INFO "the connection has been already established"
		else
			ssh -i ${private_key} ${user_name}@${host_name} -R 18080:localhost:8080 -Nf \
				&& (log INFO "completed!!") \
				|| (log ERROR "failed to connect" 1>&2; exit 1)
		fi
		;;
	"shutting-down" | "terminated" )
		echo "the instance ${instance_id} has been terminated." 1>&2
		exit 1
		;;
	"stoppting" | "stopped" )
		echo "the instance ${instance_id} has been stopped. please start up if you want to connect" 1>&2
		exit 1
		;;
	* )
		echo "the status name is invalid. status: ${status}
		      see https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-instance-status.html" 1>&2
		exit 1
		;;
esac

