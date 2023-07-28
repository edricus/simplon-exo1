#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
sudo apt-get update && sudo apt-get install dialog apt-utils docker.io docker-compose -y
mkdir npm
cat << EOF > npm/docker-compose.yml
version: '3'
services:
  app:
    image: 'jc21/nginx-proxy-manager:latest'
    restart: unless-stopped
    ports:
      - '80:80' # Public HTTP Port
      - '443:443' # Public HTTPS Port
      - '81:81' # Admin Web Port

    volumes:
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt
EOF
(cd npm ; docker-compose up -d)


