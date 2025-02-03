# 提升执行策略权限
Set-ExecutionPolicy RemoteSigned -Force

# 配置防火墙规则
New-NetFirewallRule -DisplayName "Allow WinRM HTTPS" -Direction Inbound -LocalPort 5986 -Protocol TCP -Action Allow 