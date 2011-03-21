#
# Cookbook Name:: cc_rails_app
# Recipe:: default
#
# Copyright 2011, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#


include_recipe "apache2"
include_recipe "rails"
include_recipe "bundler"
include_recipe "xml"
include_recipe "git"

user node[:cc_rails_app][:user] do
  comment "rails apps user"
end
