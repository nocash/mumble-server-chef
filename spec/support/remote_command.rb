require_relative "./shell_command"

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
