define :nginx_addon_passenger do
  gem_package "passenger"

  # recipe not finished yet
  # todo: extract passenger path from gem
  # passenger_path = ...
  node.set[:nginx][:configure_flags] << "--add-module=#{passenger_path}"
end
