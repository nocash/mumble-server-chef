directory "#{ENV['HOME']}/.aws" do
  action :create
end

template "#{ENV['HOME']}/.aws/credentials" do
  backup false
  source 'aws-credentials.erb'

  secret_key_path =
    "#{ENV['HOME']}/chef-credentials-secret-key"
  secret_key =
    Chef::EncryptedDataBagItem.load_secret(secret_key_path)
  aws_credentials =
    Chef::EncryptedDataBagItem.load('credentials', 'aws', secret_key)

  variables :credentials => {
    aws_access_key_id: aws_credentials['aws_access_key_id'],
    aws_secret_access_key: aws_credentials['aws_secret_access_key'],
  }
end

template "#{ENV['HOME']}/.aws/config" do
  source 'aws-config.erb'
end
