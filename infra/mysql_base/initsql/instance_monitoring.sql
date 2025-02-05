CREATE TABLE `instance_monitoring` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `instance_id` INT NOT NULL COMMENT '关联 instances 表的 id',
  `monitor_port` INT NOT NULL COMMENT '监控端口号，通常与实例 port 保持一致',
  `status` ENUM('up', 'down') NOT NULL DEFAULT 'up' COMMENT '服务状态：up 表示正常，down 表示异常',
  `last_checked_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后一次监控检测时间',
  `remark` VARCHAR(256) DEFAULT NULL COMMENT '附加说明',
  FOREIGN KEY (`instance_id`) REFERENCES `instances`(`id`) ON DELETE CASCADE,
  KEY `idx_instance_id` (`instance_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4; 