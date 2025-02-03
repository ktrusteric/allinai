-- 实例状态表（简化版）
CREATE TABLE IF NOT EXISTS instance_status (
    snapshot_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    instance_id VARCHAR(36) NOT NULL,
    status ENUM('healthy','warning','critical') NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (instance_id) REFERENCES openresty_instances(instance_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 监控索引
CREATE INDEX IF NOT EXISTS idx_status_time ON instance_status(timestamp);
CREATE INDEX IF NOT EXISTS idx_instance_status ON instance_status(instance_id, status);