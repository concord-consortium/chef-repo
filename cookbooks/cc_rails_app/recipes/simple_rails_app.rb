#
# Cookbook Name:: cc_rails_app
# Recipe:: portal
#
# Copyright 2011, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "unzip"
include_recipe "xslt"

include_recipe "cc_rails_app::default"

cc_rails_app "portal" do
  app :portal
end

service "httpd" do
  action :restart
end

