# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "precise32"
  config.vm.box_url = "http://files.vagrantup.com/precise32.box"

  config.ssh.forward_agent = true

  config.omnibus.chef_version = :latest

  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = ["chef/cookbooks"]
    chef.add_recipe "apt"
    chef.add_recipe "build-essential"
    chef.add_recipe "rvm::system"
    chef.add_recipe "rvm::vagrant"
    chef.add_recipe "rvm::user"
    chef.json = {
      :rvm => {
        'user_installs' => [
          {
            'user' => 'vagrant',
            'default_ruby' => 'ruby-1.9.3-p547',
            'rubies' => ['ruby-1.9.3-p547']
          }
        ]#,
#        "vagrant" => {
 #         "system_chef_client" => "/opt/chef/bin/chef-client",
  #        "system_solo_client" => "/opt/chef/bin/chef-solo"
   #     }
      }
    }
  end

end
