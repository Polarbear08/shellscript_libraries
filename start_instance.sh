#!/bin/bash
set -eux

# check if the instance-id(argument) is given
: $1

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
		echo "failed to get status" 1>&2
		exit 1
	else
		echo ${status}
	fi
}

# execute main procedure
instance_id=$1
status=`get_instance_state $1`

case ${status} in
	"pending" )
		echo "${instance_id} is now starting. wait a minute and retry."
		sleep 60
		bash $0 $1
		;;
	"running" )
		echo "connect to ${instance_id}..."
		ssh -i /root/.ssh/polaris.pem centos@34.202.215.167 -R 18080:localhost:8080 -Nf \
			&& echo "completed!!" \
			|| echo "failed to connect" 1>&2; exit 1
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

