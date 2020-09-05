#!/bin/bash

docker run -dit -p 8000:8000 -p 9000:9000 --name=portainer --restart=always -v portainer:/data -v /var/run/docker.sock:/var/run/docker.sock portainer/portainer-ce
