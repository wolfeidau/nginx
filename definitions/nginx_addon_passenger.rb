define :nginx_addon_passenger do
  gem_package "passenger"

  passenger_path = `passenger-config --root`.chomp + "/ext/nginx"
  node.set[:nginx][:configure_flags] << "--add-module=#{passenger_path}"
end
