#
# Cookbook Name:: cc_etc_profile
# Recipe:: default
#
# Copyright 2011, Concord Consortium
#
# All rights reserved - Do Not Redistribute
#
#

cookbook_file "/etc/profile.d/cc_paths.sh" do
  source "cc_paths.sh"
  mode "0644"
end

cookbook_file "/etc/sysconfig/iptables" do
  source "iptables"
  mode "0600"
end

# typically this will run /etc/init.d/example_service start
service "iptables" do
  action :restart
end

# move git
bash "move old git" do
  old_git = File.join('usr','local','bin','git')
  user "root"
  cwd "/tmp/"
  code <<-EOH
    mv /usr/local/bin/git /usr/local/bin/old-git
  EOH
  only_if do
    File.exists?(old_git)
  end
end

