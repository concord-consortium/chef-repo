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

execute "setup-portal-app" do
  user node[:cc_rails_portal][:user]
  cwd node[:cc_rails_portal][:root]
  command "ruby config/setup.rb -n '#{node[:cc_rails_portal][:name]}' -D #{node[:cc_rails_portal][:theme]} -u root -p '' -t #{node[:cc_rails_portal][:theme]} -y -q -f"
end

cc_rails_update_database "portal" do
  app :portal
end

if node[:cc_rails_portal][:checkout]
  execute "portal-setup" do
    user node[:cc_rails_portal][:user]
    cwd node[:cc_rails_portal][:root]
    environment ({'RAILS_ENV' => node[:rails][:environment]})
    command "yes | rake app:setup:new_app"
  end
end
