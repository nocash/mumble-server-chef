include_recipe 'ncv-server::aws'

include_recipe 'apt'
package 'gzip'

murmur_db_file = File.basename(node[:murmur][:config][:database])
murmur_path = File.dirname(node[:murmur][:config][:database])
s3_path = node[:murmur][:backups][:s3_path]

backup_path = "#{murmur_path}/backups"

bash 'initial_database_sync' do
  code <<-EOF
    service mumble-server stop
    mkdir -p #{backup_path}
    aws s3 sync #{s3_path} #{backup_path}
    rm -f #{murmur_path}/#{murmur_db_file}
    cp #{backup_path}/#{murmur_db_file} #{murmur_path}/
    chown mumble-server:mumble-server #{murmur_path}/#{murmur_db_file}
    service mumble-server start
  EOF
  creates "#{backup_path}/#{murmur_db_file}"
end

template '/etc/cron.daily/mumble-server-db-backup' do
  backup false
  mode 755
  source 'mumble-server-db-backup.sh.erb'
end
