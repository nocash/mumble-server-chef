require "spec_helper"
require "open3"

describe "A newly provisioned server" do
  before :context do
    next
    reinstall_cookbooks
    vm.destroy
    vm.boot
    vm.send_file secret_key_file
    vm.provision
  end

  it "can be connected to via SSH" do
    expect(vm).to have_ssh
  end

  context "with murmur installed", :murmur do
    it "is running the murmur service" do
      command = vm.run "service --status-all 2>&1"

      expect(command.output).to match "mumble-server"
    end

    it "installed murmur to /var/lib" do
      command = vm.run "ls /var/lib"

      expect(command.output).to match "mumble-server"
    end

    it "created a database backup directory" do
      command = vm.run "sudo ls /var/lib/mumble-server/backups"

      expect(command.output)
        .to match("mumble-server.sqlite")
        .and match(/mumble-server\.\d{14}\.sqlite\.gz/)
    end

    it "has a database matching the most recent murmur backup" do
      command = vm.run "sudo diff /var/lib/mumble-server/{,backups}/mumble-server.sqlite"

      expect(command.output).to be_empty
    end

    it "runs a murmur database backup script daily" do
      command = vm.run "ls /etc/cron.daily/mumble-server-db-backup"

      expect(command.output).to eq "/etc/cron.daily/mumble-server-db-backup\n"
    end
  end

  context "with AWS installed", :aws do
    pending
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

  class ShellCommand < Struct.new(:command)
    attr_reader :output, :error, :status

    def run
      exec prepare_command(command)
      self
    end

    private

    def exec(command)
      @output, @error, @status = Open3.capture3(command)
    end

    def prepare_command(command)
      command
    end
  end

  class VirtualMachine
    def ip       ; "127.0.0.1" ; end
    def name     ; "vagrant"   ; end
    def ssh_port ; 2222        ; end
    def user     ; "vagrant"   ; end

    def boot
      `vagrant up --no-provision`
    end

    def destroy
      `vagrant destroy --force`
    end

    def provision
      `knife solo bootstrap #{name} #{ssh_opts}`
    end

    def run(command)
      RemoteCommand.new(command, server: self).run
    end

    def has_ssh?
      run("ls").status.success?
    end

    def send_file(file_path, remote_path: "")
      `scp #{ssh_opts} #{file_path} #{name}:#{remote_path}`
    end

    def ssh_opts
      "-F #{ENV["HOME"]}/.ssh/config"
    end

    private

    class RemoteCommand < ShellCommand
      def initialize(command, server:)
        super(command)
        @server = server
      end

      private

      attr_reader :server

      def prepare_command(command)
        escape(command).prepend("ssh #{server.ssh_opts} #{server.name} ")
      end

      def escape(command)
        Shellwords.shellescape(command)
      end
    end
  end
end
