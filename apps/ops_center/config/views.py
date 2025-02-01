from rest_framework import generics
from .models import NginxConfig

class NginxConfigView(generics.RetrieveUpdateAPIView):
    queryset = NginxConfig.objects.all()
    serializer_class = NginxConfigSerializer

    def perform_update(self, serializer):
        instance = serializer.save()
        # 触发Ansible下发配置
        deploy_config.delay(instance.id)  # 使用Celery异步任务

class ConfigHistoryView(generics.ListAPIView):
    """配置版本历史"""
    serializer_class = ConfigHistorySerializer
    
    def get_queryset(self):
        return NginxConfig.history.filter(config_id=self.kwargs['pk']) 