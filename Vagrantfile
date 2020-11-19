# -*- mode: ruby -*-
# vim: set ft=ruby :
# -*- mode: ruby -*-
# vim: set ft=ruby :

MACHINES = {
  :inetRouter => {
    :box_name => "centos/7",
    :net => [
               {ip: '10.1.1.1', adapter: 2, netmask: "255.255.255.252", virtualbox__intnet: "router-net"},
            ]
  },
  :inetRouter2 => {
    :box_name => "centos/7",
    :net => [
               {ip: '10.2.2.1', adapter: 2, netmask: "255.255.255.252", virtualbox__intnet: "router-net1"},
               {ip: '192.168.12.12', adapter: 3, netmask: "255.255.255.0"},            
            ]
  },
  :centralRouter => {
    :box_name => "centos/7",
    :net => [
               {ip: '10.1.1.2', adapter: 2, netmask: "255.255.255.252", virtualbox__intnet: "router-net"},
               {ip: '10.2.2.2', adapter: 3, netmask: "255.255.255.252", virtualbox__intnet: "router-net1"},
               {ip: '192.168.0.33', adapter: 4, netmask: "255.255.255.240", virtualbox__intnet: "hw-net"},
            ]
  },
  :centralServer => {
    :box_name => "centos/7",
    :net => [
               {ip: '192.168.0.40', adapter: 2, netmask: "255.255.255.240", virtualbox__intnet: "hw-net"},
            ]
  },
}

Vagrant.configure("2") do |config|
  config.vbguest.auto_update = false
  config.vm.provider "virtualbox" do |vb|
    vb.memory = 256
    vb.cpus = 1
  end
  
  MACHINES.each do |boxname, boxconfig|

    config.vm.define boxname do |box|
        box.vm.box = boxconfig[:box_name]
        box.vm.host_name = boxname.to_s
        
        boxconfig[:net].each do |ipconf|
            box.vm.network "private_network", ipconf
        end
        
        box.vm.provision "shell", inline: <<-SHELL
            mkdir -p ~root/.ssh
            cp ~vagrant/.ssh/auth* ~root/.ssh
        SHELL
        
        case boxname.to_s
        when "inetRouter"
          box.vm.provision "shell", inline: <<-SHELL
            cp -f /vagrant/routes/ip_forwarding.conf /etc/sysctl.d/ip_forwarding.conf
#            echo "DEFROUTE=no" >> /etc/sysconfig/network-scripts/ifcfg-eth0
#            ip route del default
            systemctl restart network
            cp -f /vagrant/routes/inetRouter-eth1 /etc/sysconfig/network-scripts/route-eth1
            systemctl restart network
            useradd user1
            echo "user" | passwd --stdin user1
            sed -i 's/^PasswordAuthentication.*$/PasswordAuthentication yes/' /etc/ssh/sshd_config && systemctl restart sshd.service
            yum install -y iptables-services
            systemctl enable --now iptables
            iptables-restore < /vagrant/firewall/inetrouter.rules
            service iptables save
            SHELL
        when "inetRouter2"
          box.vm.provision "shell", inline: <<-SHELL
            yum install -y iptables-services tcpdump wireshark conntrack-tools
            systemctl enable --now iptables
            cp -f /vagrant/routes/ip_forwarding.conf /etc/sysctl.d/ip_forwarding.conf
            echo "DEFROUTE=no" >> /etc/sysconfig/network-scripts/ifcfg-eth0
            ip route del default
            systemctl restart network
            cp -f /vagrant/routes/inetRouter2-eth1 /etc/sysconfig/network-scripts/route-eth1
            systemctl restart network
            iptables -F
            iptables -t nat -A PREROUTING -i eth2 -p tcp --dport 8080 -j DNAT --to 192.168.0.40:80
            service iptables save
            SHELL
        when "centralRouter"
          box.vm.provision "shell", inline: <<-SHELL
            cp -f /vagrant/routes/ip_forwarding.conf /etc/sysctl.d/ip_forwarding.conf
            echo "DEFROUTE=no" >> /etc/sysconfig/network-scripts/ifcfg-eth0 
            ip route del default
            systemctl restart network
            echo "GATEWAY=10.1.1.1" >> /etc/sysconfig/network-scripts/ifcfg-eth1
            cp -f /vagrant/routes/centralRouter-eth2 /etc/sysconfig/network-scripts/route-eth2
            systemctl restart network
            yum install -y nmap
            cp /vagrant/sources/knock.sh /opt
            chmod +x /opt/knock.sh
            SHELL
        when "centralServer"
          box.vm.provision "shell", inline: <<-SHELL
            echo "DEFROUTE=no" >> /etc/sysconfig/network-scripts/ifcfg-eth0
            ip route del default
            systemctl restart network
            echo "GATEWAY=192.168.0.33" >> /etc/sysconfig/network-scripts/ifcfg-eth1
            systemctl restart network
            yum install -y epel-release
            yum install -y nginx
            cp -f /vagrant/sources/index.html /usr/share/doc/HTML/index.html
            systemctl enable --now nginx
            SHELL
        end
      end
  end
end