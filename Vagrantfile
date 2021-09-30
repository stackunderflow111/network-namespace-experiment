Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64"
  config.vm.define "host", primary: true do |host|
    host.vm.hostname = "host"
    host.vm.network "private_network", ip: "172.16.1.4"
    host.vm.provision "shell", path: "configure.sh"
  end
  
  config.vm.define "guest" do |guest|
    guest.vm.hostname = "guest"
    guest.vm.network "private_network", ip: "172.16.1.5"
  end
end