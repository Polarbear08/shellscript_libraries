#!/bin/bash

wget https://github.com/nginxinc/nginx-prometheus-exporter/releases/download/v0.4.2/nginx-prometheus-exporter-0.4.2-linux-amd64.tar.gz
tar zxvf nginx-prometheus-exporter-0.4.2-linux-amd64.tar.gz
mv nginx-prometheus-exporter /usr/local/

cat << EOF > /lib/systemd/system/nginx-prometheus-exporter.service
[Unit]
Description=nginx for Prometheus

[Service]
Restart=always
User=root
ExecStart=/usr/local/nginx-prometheus-exporter -nginx.scrape-uri ホスト/stub_status
ExecReload=/bin/kill -HUP $MAINPID
TimeoutStopSec=20s
SendSIGKILL=no

[Install]
WantedBy=multi-user.target
EOF

systemctl enable nginx-prometheus-exporter.service
systemctl start nginx-prometheus-exporter.service
ufw allow 9113/tcp

