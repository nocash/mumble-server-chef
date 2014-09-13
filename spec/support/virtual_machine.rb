class VirtualMachine
  def ip       ; "127.0.0.1" ; end
  def name     ; "vagrant"   ; end
  def ssh_port ; 2222        ; end
  def user     ; "vagrant"   ; end

  def boot
    sh "vagrant up --no-provision"
  end

  def destroy
    sh "vagrant destroy --force"
  end

  def provision
    sh "knife solo bootstrap #{name} #{ssh_opts}"
  end

  def run(command)
    RemoteCommand.new(command, server: self).run
  end

  def has_ssh?
    run("echo OK").status.success?
  end

  def send_file(file_path, remote_path: "")
    `scp #{ssh_opts} #{file_path} #{name}:#{remote_path}`
  end

  def ssh_opts
    "-F #{ENV["HOME"]}/.ssh/config"
  end

  private

  def sh(command)
    ShellCommand.new(command).run
  end
end
