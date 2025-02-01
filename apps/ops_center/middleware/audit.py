class ConfigAuditMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        response = self.get_response(request)
        
        if request.path.startswith('/api/config') and request.method in ['PUT', 'POST']:
            AuditLog.objects.create(
                user=request.user,
                action=request.method,
                path=request.path,
                changes=request.data.dict()
            )
        
        return response 