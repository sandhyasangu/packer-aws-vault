#!/bin/bash
/usr/local/bin/ansible-playbook -i localhost -t 'rotate-certificate' /opt/packer/ansible/vault.yml
