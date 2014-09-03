chef_user = node[:current_user]
home_dir = Dir.home(chef_user)

directory "#{home_dir}/.aws" do
  action :create
  group chef_user
  mode 00700
  owner chef_user
end

template "#{home_dir}/.aws/credentials" do
  backup false
  group chef_user
  mode 0600
  owner chef_user
  source 'aws-credentials.erb'

  secret_key_path =
    "#{home_dir}/chef-credentials-secret-key"
  secret_key =
    Chef::EncryptedDataBagItem.load_secret(secret_key_path)
  aws_credentials =
    Chef::EncryptedDataBagItem.load('credentials', 'aws', secret_key)

  variables :credentials => {
    aws_access_key_id: aws_credentials['aws_access_key_id'],
    aws_secret_access_key: aws_credentials['aws_secret_access_key'],
  }
end

template "#{home_dir}/.aws/config" do
  group chef_user
  mode 0600
  owner chef_user
  source 'aws-config.erb'
end
