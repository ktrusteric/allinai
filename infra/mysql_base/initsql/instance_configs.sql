CREATE TABLE `instance_configs` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `instance_id` INT NOT NULL COMMENT '关联 instances 表的 id',
  `config_content` TEXT NOT NULL COMMENT '自动生成的配置文件完整内容（包含所有 include 部分）',
  `version` VARCHAR(64) NOT NULL COMMENT '配置版本号，例如时间戳或递增版本号',
  `change_log` VARCHAR(512) DEFAULT NULL COMMENT '配置变更描述或修改记录',
  `include_file_names` TEXT DEFAULT NULL COMMENT 'JSON数组，包含本配置引用的所有 include 文件名称',
  `deployed` BOOLEAN DEFAULT FALSE COMMENT '是否已发布到实例（热加载）',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '配置生成时间',
  FOREIGN KEY (`instance_id`) REFERENCES `instances`(`id`) ON DELETE CASCADE,
  KEY `idx_instance_id` (`instance_id`),
  KEY `idx_version` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4; 