#!/bin/bash

docker run \
  -dit \
  --name jenkins \
  --network jenkins \
  --publish 8080:8080 \
  --publish 50000:5000 \
  --volume /var/run/docker.sock:/var/run/docker.sock \
  --volume jenkins:/var/jenkins_home \
  --group-add $(stat -c '%g' /var/run/docker.sock) \
  --group-add $(stat -c '%g' /bin/docker) \
  --dns=1.1.1.1 \
  --env JENKINS_OPTS="--prefix=/jenkins" \
  jenkinsci/blueocean

