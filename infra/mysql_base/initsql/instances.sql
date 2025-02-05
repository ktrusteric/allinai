CREATE TABLE `instances` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `instanceid` VARCHAR(64) NOT NULL UNIQUE COMMENT '实例唯一标识，如 prd_payment_001_8080',
  `env` VARCHAR(16) NOT NULL COMMENT '运行环境，如 prd 或 dev',
  `module` VARCHAR(32) NOT NULL COMMENT '业务模块，如 payment、order',
  `port` INT NOT NULL COMMENT '监听端口',
  `target_type` VARCHAR(32) NOT NULL DEFAULT 'physical' COMMENT '目标类型，如 physical(物理机), virtual(虚拟机), container(容器)',
  `target_ip` VARCHAR(45) NOT NULL COMMENT '目标主机 IP 地址',
  `description` VARCHAR(256) DEFAULT NULL COMMENT '实例描述或附加信息',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  KEY `idx_target_ip` (`target_ip`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;