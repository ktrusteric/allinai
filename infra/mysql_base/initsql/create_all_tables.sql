-- 禁用外键检查，方便 DROP 和重建表结构
SET FOREIGN_KEY_CHECKS = 0;

-- 如果已存在则删除旧表
DROP TABLE IF EXISTS `instance_monitoring`;
DROP TABLE IF EXISTS `instance_config_includes`;
DROP TABLE IF EXISTS `instance_configs`;
DROP TABLE IF EXISTS `instances`;

SET FOREIGN_KEY_CHECKS = 1;

/* ----------------------------------------------------------------
   1. 创建实例基本信息表：instances
   ---------------------------------------------------------------- */
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

/* ----------------------------------------------------------------
   2. 创建实例配置记录表：instance_configs
      用于记录自动生成的整体配置内容、版本、变更说明及引用的 include 文件名称
   ---------------------------------------------------------------- */
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

/* ----------------------------------------------------------------
   3. 创建 include 模块配置明细记录表：instance_config_includes
      用于记录自动生成的每个 include 文件中详细的 server 和 location 配置（JSON 格式）
   ---------------------------------------------------------------- */
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

/* ----------------------------------------------------------------
   4. 创建实例监控表：instance_monitoring
      用于记录每个实例的监控端口、服务状态及最后检测时间
   ---------------------------------------------------------------- */
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