#
# Cookbook Name:: cc_etc_profile
# Recipe:: default
#
# Copyright 2011, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
#

cookbook_file "/etc/profile" do
  source "profile"
  mode "0644"
end

