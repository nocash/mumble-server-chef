include_recipe 'apt'
package 'gzip'
package 'sqlite3'

template '/etc/mumble-server.ini' do
  group 'mumble-server'
  source 'mumble-server.ini.erb'
  user 'root'
  notifies :restart, 'service[mumble-server]'
end

template '/etc/cron.daily/mumble-server-db-backup' do
  backup false
  mode 755
  source 'mumble-server-db-backup.sh.erb'
end
