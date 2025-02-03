def sync_install_paths():
    """从数据库同步路径到配置中心"""
    paths = db.query("SELECT version, install_path, bin_path FROM openresty_installations")
    etcd_client.put('/allinai/openresty/paths', json.dumps(paths)) 