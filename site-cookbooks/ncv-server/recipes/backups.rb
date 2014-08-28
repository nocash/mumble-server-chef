include_recipe 'apt'
package 'gzip'

template '/etc/cron.daily/mumble-server-db-backup' do
  backup false
  mode 755
  source 'mumble-server-db-backup.sh.erb'
end
