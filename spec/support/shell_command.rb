require "open3"

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
