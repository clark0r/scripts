#!/bin/sh
# configure security contact / alerts for all subscriptions in azure tenant
# required: az cli, security admin role on subscriptions

for s in $(az account list --all -o tsv | awk '{print $3}'); 
do 
 az security contact create --name defenderalert --email 'security@domain.com' --alert-notifications 'on' --alerts-admins 'on' --subscription ${s}; 
done
