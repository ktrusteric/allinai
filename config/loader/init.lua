local mysql = require "resty.mysql"
local file_sys = require "config.file_system"

local _M = {}

function _M.load(instance_id)
    local db, err = mysql:new()
    if not db then
        ngx.log(ngx.ERR, "failed to instantiate mysql: ", err)
        return nil, err
    end

    db:set_timeout(1000) -- 1秒超时

    local ok, err, errcode, sqlstate = db:connect{
        host = "mysql",
        port = 3306,
        database = "allinai_config",
        user = "root",
        password = "SecurePass123!",
        max_packet_size = 1024 * 1024
    }

    if not ok then
        ngx.log(ngx.ERR, "failed to connect: ", err, ": ", errcode, " ", sqlstate)
        return nil, err
    end

    -- 查询最新配置
    local res, err, errcode, sqlstate = db:query(
        "SELECT config_content, config_type FROM config_versions "..
        "WHERE instance_id = '"..instance_id.."' ORDER BY version_id DESC LIMIT 1"
    )

    if not res then
        ngx.log(ngx.ERR, "bad result: ", err, ": ", errcode, ": ", sqlstate, ".")
        return nil, err
    end

    -- 生成临时配置文件
    local temp_path = "/tmp/nginx/"..instance_id
    local ok = file_sys.write_file(temp_path, res[1].config_content)
    
    -- 验证配置语法
    local ok, err = ngx.config.nginx_configure()
    if not ok then
        ngx.log(ngx.ERR, "配置语法错误: ", err)
        return nil, err
    end

    return temp_path
end

return _M 