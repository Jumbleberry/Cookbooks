#!/bin/sh
exec ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i "/tmp/.ssh/deployment_key" $1 $2
