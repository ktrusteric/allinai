-- 实例表
CREATE TABLE IF NOT EXISTS openresty_instances (
    instance_id VARCHAR(36) PRIMARY KEY,
    instance_name VARCHAR(64) UNIQUE NOT NULL 
        CHECK (instance_name REGEXP '^[a-z]{3}_[a-z]+_d{3}$'),
    port INT UNIQUE NOT NULL CHECK (port BETWEEN 8000 AND 8999),
    config_path VARCHAR(255) GENERATED ALWAYS AS (
        CONCAT('/allinai/apps/openresty/', port, '/nginx/conf')
    ) STORED,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB; 

-- 配置版本表
CREATE TABLE config_versions (
    version_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    instance_id VARCHAR(36) NOT NULL,
    config_type ENUM('http','stream','lua') NOT NULL,
    config_hash CHAR(64) NOT NULL,
    config_content LONGTEXT NOT NULL,
    created_by VARCHAR(32) DEFAULT 'system',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (instance_id) REFERENCES openresty_instances(instance_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 创建索引
CREATE INDEX idx_port ON openresty_instances(port);
CREATE INDEX idx_config_instance ON config_versions(instance_id);