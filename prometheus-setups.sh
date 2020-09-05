#!/bin/bash

docker run -dit --name prometheus -p 9090:9090 -v prometheus:/etc/prometheus prom/prometheus

