# Region information to use for AWS servers.
default[:aws][:config][:default][:region] = 'us-west-2'

# Disable synced backups by default to prevent test servers from overwriting
# actual server backups. This should only be enabled for the node functioning
# as the production server.
default[:murmur][:backups][:sync] = false

# Full S3 path to use for database backups.
default[:murmur][:backups][:s3_path] = "s3://mumble-server/db-backups"

# Values to use when creating the Murmur configuration file.
default[:murmur][:config][:database] = '/var/lib/mumble-server/mumble-server.sqlite'
