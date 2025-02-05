CREATE TABLE `instance_config_includes` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `config_id` INT NOT NULL COMMENT '关联 instance_configs 表的配置ID',
  `include_filename` VARCHAR(128) NOT NULL COMMENT '自动生成的 include 文件名称',
  `server_config` TEXT NOT NULL COMMENT 'server 模块自动生成配置字段，采用 JSON 格式存储',
  `location_config` TEXT NOT NULL COMMENT 'location 模块自动生成配置字段，采用 JSON 格式存储',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '记录创建时间',
  FOREIGN KEY (`config_id`) REFERENCES `instance_configs`(`id`) ON DELETE CASCADE,
  KEY `idx_config_id` (`config_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4; 