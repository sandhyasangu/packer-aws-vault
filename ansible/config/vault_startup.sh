#!/usr/bin/env bash
#
# A one time script that runs at startup, configures vault at run time and never runs again
# wait indefinitely for all other vault_startup executions to complete
exec 100> /run/vault_startup.lock
flock 100

##Write the PID
echo $$ > /run/vault_startup.pid 

## Return values 
rval=0
ar_rval=0

## Run Runtime Ansible playbook
ansible-playbook /opt/packer/ansible/vault.yml
ar_rval=$?
 
if [ ${ar_rval} != 0 ]; then
    echo "Ansible run returned a non-zero value!! ${ar_rval}"
fi

let rval=$(( $rval + $ar_rval))

## Finished
flock -u 100
exit ${rval}

#
#EOF
#

