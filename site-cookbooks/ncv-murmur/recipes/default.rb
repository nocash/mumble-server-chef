#
# Cookbook Name:: ncv-murmur
# Recipe:: default
#
# Copyright 2014, Beau Dacious
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

include_recipe 'apt'
package 'gzip'
package 'sqlite3'

directory "#{ENV['HOME']}/.aws" do
  action :create
end

template "#{ENV['HOME']}/.aws/credentials" do
  backup false
  source 'aws-credentials.erb'
end

template "#{ENV['HOME']}/.aws/config" do
  source 'aws-config.erb'
end

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
