Vagrant.configure(2) do |config|
  # if Vagrant.has_plugin?("vagrant-cachier")
  #   config.cache.scope = :box
  # end

  config.vm.box = "bento/centos-7.1"

  # avoid mount error due to vbguest
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.provision :shell, inline: "sudo yum -y update kernel"
  # config.vm.provision :shell, inline: "sudo yum -y install kernel-devel kernel-headers dkms gcc gcc-c++"

  config.vm.define :host_a do |host|
    host.vm.hostname = "host-a.ms"
    host.vm.network "private_network", ip: ENV["VAGRANT_HOST_A"]
  end

  config.vm.define :host_c do |host|
    host.vm.hostname = "host-c.ms"
    host.vm.network "private_network", ip: ENV["VAGRANT_HOST_C"]
  end

  config.vm.synced_folder "./src/", "/vagrant"

  # config.vm.provider "virtualbox" do |vb|
  #   vb.name = "FuelPHP_with_PHP7"
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end

  config.ssh.insert_key = false
end
