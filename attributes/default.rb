default[:nginx][:version] = "1.2.0"

default[:nginx][:modules] = ["ssl", "gzip_static"]
default[:nginx][:extra_modules] = {}

case platform
when "debian","ubuntu"
  default[:nginx][:dir]        = "/etc/nginx"
  default[:nginx][:log_dir]    = "/var/log/nginx"
  default[:nginx][:user]       = "www-data"
  default[:nginx][:binary]     = "/usr/sbin/nginx"
  default[:nginx][:init_style] = "upstart"
end

default[:nginx][:gzip] = "on"
default[:nginx][:gzip_http_version] = "1.0"
default[:nginx][:gzip_comp_level] = "2"
default[:nginx][:gzip_proxied] = "any"
default[:nginx][:gzip_types] = [
  "text/plain",
  "text/css",
  "application/x-javascript",
  "text/xml",
  "application/xml",
  "application/xml+rss",
  "text/javascript",
  "application/javascript"
]

default[:nginx][:keepalive]          = "on"
default[:nginx][:keepalive_timeout]  = 65
default[:nginx][:worker_processes]   = cpu[:total]
default[:nginx][:worker_connections] = 2048
default[:nginx][:server_names_hash_bucket_size] = 64
default[:nginx][:disable_access_log] = true