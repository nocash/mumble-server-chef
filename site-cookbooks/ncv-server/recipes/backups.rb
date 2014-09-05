include_recipe 'ncv-server::aws'

include_recipe 'apt'
package 'gzip'

murmur_path = File.dirname(node[:murmur][:config][:database])
s3_path = "s3://mumble-server/db-backups"

backup_path = "#{murmur_path}/backups"

bash 'initial_database_sync' do
  code <<-EOF
    mkdir -p #{backup_path}
    aws s3 sync #{s3_path} #{backup_path}
    rm -v #{murmur_path}/mumble-server.sqlite
    cp -v #{backup_path}/mumble-server.sqlite #{murmur_path}/
    EOF
  creates "#{backup_path}/mumble-server.sqlite"
end

template '/etc/cron.daily/mumble-server-db-backup' do
  backup false
  mode 755
  source 'mumble-server-db-backup.sh.erb'
end
