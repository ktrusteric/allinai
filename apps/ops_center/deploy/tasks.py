from ansible_runner import run

@shared_task
def deploy_config(config_id):
    config = NginxConfig.objects.get(id=config_id)
    
    # 生成临时配置文件
    config_path = generate_config_file(config.content)
    
    # 执行Ansible Playbook
    res = run(
        playbook='deploy_nginx.yml',
        inventory='inventory/prod',
        extravars={
            'config_path': config_path,
            'config_checksum': config.checksum
        }
    )
    
    # 记录部署结果
    DeploymentLog.objects.create(
        config=config,
        status='SUCCESS' if res.status == 'successful' else 'FAILED',
        log=res.stdout
    ) 