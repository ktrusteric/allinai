from ansible_runner import run

def execute_playbook(playbook_path, extra_vars):
    result = run(
        playbook=playbook_path,
        inventory='infra/ansible/inventory/production',
        extravars=extra_vars
    )
    
    return {
        'status': 'success' if result.rc == 0 else 'failed',
        'stats': result.stats,
        'artifacts': result.artifacts
    }

# 调用示例
execute_playbook(
    playbook_path='infra/ansible/playbooks/deploy_mysql.yaml',
    extra_vars={
        'mysql_root_password': 'SecurePass123!',
        'web_install_path': '/opt/allinai'
    }
) 