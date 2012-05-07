define :nginx_addon_mod_zip do

  bash "fetch_code" do
    cwd Chef::Config[:file_cache_path]
    unless File.exists? "#{Chef::Config[:file_cache_path]}/mod_zip"
      code "git clone https://github.com/sam/mod_zip.git"
    end
    node.set[:nginx][:configure_flags] << "--add-module=#{Chef::Config[:file_cache_path]}/mod_zip"
  end

end
