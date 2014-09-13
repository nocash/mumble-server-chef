template '/etc/mumble-server.ini' do
  group 'mumble-server'
  source 'mumble-server.ini.erb'
  user 'root'
  notifies :restart, 'service[mumble-server]'
end
