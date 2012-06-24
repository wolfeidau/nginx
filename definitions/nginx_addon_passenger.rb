define :nginx_addon_passenger do
  gem_package "passenger"

  node.set[:nginx][:passenger_root] = `passenger-config --root`.chomp
  node.set[:nginx][:passenger_ruby] = "/usr/bin/ruby"

  passenger_path = node[:nginx][:passenger_root] + "/ext/nginx"
  node.set[:nginx][:configure_flags] << "--add-module=#{passenger_path}"
end
