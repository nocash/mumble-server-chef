require "spec_helper"

describe "A newly provisioned server" do
  before :context do
    next # only need to test the full process occasionaly
    reinstall_cookbooks
    vm.destroy
    vm.boot
    vm.send_file secret_key_file
    vm.provision
  end

  it "can be connected to via SSH" do
    expect(vm).to have_ssh
  end

  context "with Murmur installed", :Murmur do
    it "is running the Murmur service" do
      command = vm.run "service --status-all 2>&1"

      expect(command.output).to match "mumble-server"
    end

    it "installed Murmur to /var/lib" do
      command = vm.run "ls /var/lib"

      expect(command.output).to match "mumble-server"
    end

    it "created a Murmur configuration file" do
      command = vm.run "ls /etc/mumble-server.ini"

      expect(command.status).to be_success
    end

    it "customized the Murmur configuration file" do
      command = vm.run "sudo grep 'registerName=' /etc/mumble-server.ini"

      expect(command.output).to eq "registerName=NO CASH VALUE\n"
    end

    it "created a database backup directory" do
      command = vm.run "sudo ls /var/lib/mumble-server/backups"

      expect(command.output)
        .to match("mumble-server.sqlite")
        .and match(/mumble-server\.\d{14}\.sqlite\.gz/)
    end

    it "has a database matching the most recent Murmur backup" do
      command = vm.run "sudo diff /var/lib/mumble-server/{,backups}/mumble-server.sqlite"

      expect(command.output).to be_empty
    end

    it "runs a Murmur database backup script daily" do
      command = vm.run "ls /etc/cron.daily/mumble-server-db-backup"

      expect(command.output).to eq "/etc/cron.daily/mumble-server-db-backup\n"
    end
  end

  context "with AWS installed", :aws do
    it "creates the AWS configuration files" do
      command = vm.run "ls ~/.aws"

      expect(command.output)
        .to match("config")
        .and match("credentials")
    end

    it "sets the region" do
      command = vm.run "grep 'us-west-2' ~/.aws/config"

      expect(command.output).to eq "region = us-west-2\n"
    end

    it "sets the AWS credentials" do
      command = vm.run "cat ~/.aws/credentials"

      expect(command.output)
        .to match("aws_access_key_id =")
        .and match("aws_secret_access_key = ")
    end

    it "can copy files from S3" do
      command = vm.run "aws s3 cp s3://mumble-server/db-backups/mumble-server.sqlite /tmp/"

      expect(command.status).to be_success
    end
  end

  def secret_key_file
    "#{ENV["HOME"]}/.ssh/chef-credentials-secret-key"
  end

  def reinstall_cookbooks
    `librarian-chef clean`
    `librarian-chef install`
  end

  def vm
    @virtual_machine ||= VirtualMachine.new
  end
end
