define :nginx_addon_syslog do

  # "https://raw.github.com/yaoweibin/nginx_syslog_patch/master/syslog_1.2.0.patch"
  bash "fetch_code" do
    cwd Chef::Config[:file_cache_path]
    unless File.exists? "#{Chef::Config[:file_cache_path]}/nginx_syslog_patch"
      code "git clone https://github.com/yaoweibin/nginx_syslog_patch.git"
    end
  end

  bash "patch_nginx" do
    cwd "#{Chef::Config[:file_cache_path]}/nginx-#{node[:nginx][:version]}"
    code "patch -p1 < #{Chef::Config[:file_cache_path]}/nginx_syslog_patch/syslog_#{node[:nginx][:version]}.patch"
  end

  node.set[:nginx][:configure_flags] << "--add-module=#{Chef::Config[:file_cache_path]}/nginx_syslog_patch"
end
