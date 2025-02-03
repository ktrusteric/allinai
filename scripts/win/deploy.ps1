$Env:ANSIBLE_CONFIG = "$PSScriptRoot\..\env\windows\ansible.cfg"
ansible-playbook -i env/windows/inventory/production playbooks/deploy_all.yml 