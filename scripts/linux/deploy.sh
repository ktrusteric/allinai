export ANSIBLE_CONFIG=$(pwd)/env/linux/ansible.cfg
ansible-playbook -i env/linux/inventory/production playbooks/deploy_all.yml 