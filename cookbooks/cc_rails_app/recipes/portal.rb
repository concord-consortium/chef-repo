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

root = node[:cc_rails_app][:portal][:root]
root = File.join(root,"current") if node[:cc_rails_app][:portal][:capistrano_folders]

execute "setup-portal-app" do
  user node[:cc_rails_app][:user]
  cwd root
  command "ruby config/setup.rb -n '#{node[:cc_rails_app][:portal][:name]}' -D #{node[:cc_rails_app][:portal][:theme]} -u root -p '' -t #{node[:cc_rails_app][:portal][:theme]} -y -q -f"
end

cc_rails_update_database "portal" do
  app :portal
end

if node[:cc_rails_app][:checkout]
  execute "portal-setup" do
    user node[:cc_rails_app][:user]
    cwd root
    environment ({'RAILS_ENV' => node[:rails][:environment]})
    command "yes | rake app:setup:new_app"
  end

  execute "create-asset-packages" do
    user node[:cc_rails_app][:user]
    cwd root
    command "compass --sass-dir public/stylesheets/sass/ --css-dir public/stylesheets/ -s compressed --force; rake asset:packager:build_all"
  end
end
