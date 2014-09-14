default[:aws][:config][:default][:region] = 'us-west-2'
default[:murmur][:backups][:s3_path] = "s3://mumble-server/db-backups"
default[:murmur][:config][:database] = '/var/lib/mumble-server/mumble-server.sqlite'
