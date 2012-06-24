package "libpcre3-dev"
package "libssl-dev"

nginx_version = node[:nginx][:version]

# Fetch the nginx tarball
remote_file "#{Chef::Config[:file_cache_path]}/nginx-#{nginx_version}.tar.gz" do
  source "http://nginx.org/download/nginx-#{nginx_version}.tar.gz"
  action :create_if_missing
end

bash "extract_tarball" do
  cwd Chef::Config[:file_cache_path]
  # puts "cd nginx-#{nginx_version} && ./configure #{configure_flags}"
  code "tar zxf nginx-#{nginx_version}.tar.gz"
end

# Set configure options
node.set[:nginx][:install_path]    = "/opt/nginx-#{nginx_version}"
node.set[:nginx][:src_binary]      = "#{node[:nginx][:install_path]}/sbin/nginx"
node.set[:nginx][:configure_flags] = [
  "--prefix=#{node[:nginx][:install_path]}",
  "--conf-path=#{node[:nginx][:dir]}/nginx.conf",
  "--http-log-path=#{node[:nginx][:log_dir]}/access.log",
  "--error-log-path=#{node[:nginx][:log_dir]}/error.log"
] + node[:nginx][:modules].map { |the| "--with-http_#{the}_module" }

# Add extra modules
node[:nginx][:extra_modules].each do |addon|
  send :"nginx_addon_#{addon}" 
end

configure_flags = node[:nginx][:configure_flags].join " "

bash "compile_nginx_source" do
  cwd "#{Chef::Config[:file_cache_path]}/nginx-#{nginx_version}"
  # puts "cd nginx-#{nginx_version} && ./configure #{configure_flags}"
  code <<-EOH
    ./configure #{configure_flags}
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

if node[:nginx][:extra_modules].include? "passenger"
  template "passenger.conf" do
    path "#{node[:nginx][:dir]}/conf.d/passenger.conf"
    source "passenger.conf.erb"
    notifies :restart, resources(:service => "nginx"), :immediately                                                        
  end
end
