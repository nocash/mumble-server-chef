name             'murmur-too'
maintainer       'Beau Dacious'
maintainer_email 'z727090@gmail.com'
license          'MIT'
description      'Installs/Configures murmur'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

# TODO: support adding of mumble apt repository
# TODO: support creating config file from other cookbook
# TODO: support user/group other than "mumble-server"

depends 'apt'
supports 'ubuntu'
