maintainer        "Skalar AS"
maintainer_email  "gr@skalar.no"
license           "Apache 2.0"
description       "Installs and configures nginx"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "0.0.1"

recipe "nginx",   "Installs nginx"

supports "ubuntu"
