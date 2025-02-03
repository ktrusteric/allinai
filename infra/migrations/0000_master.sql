-- 迁移执行顺序控制文件
-- 执行顺序：数字编号从小到大

-- 2024-06-21 初始化核心表结构
SOURCE 0001_init_database.sql;
SOURCE 0002_core_tables.sql;
SOURCE 0003_monitoring.sql;