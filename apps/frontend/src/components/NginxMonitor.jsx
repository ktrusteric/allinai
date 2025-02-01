import { usePrometheus } from './hooks/prometheus';

export default function NginxMonitor() {
  const { data: reqData } = usePrometheus(
    'rate(nginx_http_requests_total[5m])'
  );
  
  const { data: errorData } = usePrometheus(
    'rate(nginx_http_requests_errors{status=~"4xx|5xx"}[5m])'
  );

  return (
    <div>
      <LineChart data={reqData} title="请求率" />
      <LineChart data={errorData} title="错误率" />
    </div>
  )
} 