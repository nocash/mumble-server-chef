require "spec_helper"
require "open3"

describe "A newly provisioned server" do
  before :context do
    reinstall_cookbooks
    vm.destroy
    vm.boot
    vm.send_file secret_key_file
    vm.provision
  end

  it "can be connected to via SSH" do
    expect(vm).to have_ssh
  end

  it "has murmur installed" do
    command = vm.run "service --status-all"

    expect(command.output).to match "mumble-server"
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

  ShellCommand = Struct.new(:command) do
    attr_reader :output, :status

    def run
      exec prepare_command(command)
      self
    end

    private

    def exec(command)
      @output, @status = Open3.capture2e(command)
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
