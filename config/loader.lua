function load_config_from_db()
    local db = mysql:new()
    db:connect{
        host = "mysql",
        database = "allinai_config",
        user = "root",
        password = "SecurePass123!"
    }
    
    local res, err = db:query("SELECT * FROM config_versions 
                              WHERE instance_id = ? ORDER BY version_id DESC LIMIT 1", 
                              ngx.var.instance_id)
    
    if not res then
        ngx.log(ngx.ERR, "配置加载失败: ", err)
        return nil
    end
    
    return res[1].config_content
end 