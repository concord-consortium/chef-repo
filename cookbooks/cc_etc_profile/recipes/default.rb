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
