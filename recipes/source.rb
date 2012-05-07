package "libpcre3-dev"
package "libssl-dev"

nginx_version = node[:nginx][:version]

node.set[:nginx][:install_path]    = "/opt/nginx-#{nginx_version}"
node.set[:nginx][:src_binary]      = "#{node[:nginx][:install_path]}/sbin/nginx"
node.set[:nginx][:configure_flags] = [
  "--prefix=#{node[:nginx][:install_path]}",
  "--conf-path=#{node[:nginx][:dir]}/nginx.conf"
] + node[:nginx][:modules].map { |a| "--with-http_#{a}_module" }

# Extra modules
node[:nginx][:extra_modules].each do |addon|
  send :"nginx_addon_#{addon}" 
end

configure_flags = node[:nginx][:configure_flags].join " "

remote_file "#{Chef::Config[:file_cache_path]}/nginx-#{nginx_version}.tar.gz" do
  source "http://nginx.org/download/nginx-#{nginx_version}.tar.gz"
  action :create_if_missing
end

bash "compile_nginx_source" do
  cwd Chef::Config[:file_cache_path]
  puts "cd nginx-#{nginx_version} && ./configure #{configure_flags}"
  code <<-EOH
    tar zxf nginx-#{nginx_version}.tar.gz
    cd nginx-#{nginx_version} && ./configure #{configure_flags}
    make && make install
  EOH
  creates node[:nginx][:src_binary]
end

user node[:nginx][:user] do
  system true
  shell "/bin/false"
  home "/var/www"
end

directory node[:nginx][:log_dir] do
  mode 0755
  owner node[:nginx][:user]
  action :create
end

directory node[:nginx][:dir] do
  owner "root"
  group "root"
  mode "0755"
end

%w{ sites-available sites-enabled conf.d }.each do |dir|
  directory "#{node[:nginx][:dir]}/#{dir}" do
    owner "root"
    group "root"
    mode "0755"
  end
end

# Init script
case node[:nginx][:init_style]
when "upstart"
  template "/etc/init/nginx.conf" do
    source "nginx.upstart.erb"
    owner "root"
    group "root"
    mode "0644"
  end
end

service "nginx" do
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => true, :reload => true
  action :enable
  subscribes :restart, resources(:bash => "compile_nginx_source")
end

template "nginx.conf" do
  path "#{node[:nginx][:dir]}/nginx.conf"
  source "nginx.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "nginx"), :immediately
end

cookbook_file "#{node[:nginx][:dir]}/mime.types" do
  source "mime.types"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "nginx"), :immediately
end

