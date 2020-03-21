#!/bin/bash

sudo /etc/init.d/mysql stop
sudo chmod o+w /etc/hosts
sudo echo "127.0.0.1	keycloak" >> /etc/hosts
