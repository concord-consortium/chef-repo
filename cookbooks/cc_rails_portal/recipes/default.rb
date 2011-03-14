#
# Cookbook Name:: cc_rails_portal
# Recipe:: default
#
# Copyright 2011, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "apache2"
include_recipe "rails"
include_recipe "unzip"
include_recipe "xslt"
include_recipe "bundler"

web_app "project" do
  template "rails_app.conf.erb"
  docroot node[:cc_rails_portal][:root] + "/public"
  rails_env node[:rails][:environment]
  notifies :reload, resources(:service => "apache2"), :delayed
end

user node[:cc_rails_portal][:user] do
  comment "portal user"
  system true
  shell "/bin/false"
end

if node[:cc_rails_portal][:checkout] == "true"
  git node[:cc_rails_portal][:root] do
    repository node[:cc_rails_portal][:source_url]
    reference node[:cc_rails_portal][:source_branch]
    action :sync
  end
end

execute "bundle-install" do
  user node[:cc_rails_portal][:user]
  cwd node[:cc_rails_portal][:root]
  command "bundle install"
end

execute "setup-xportal-app" do
  user node[:cc_rails_portal][:user]
  cwd node[:cc_rails_portal][:root]
  command "ruby config/setup.rb -n '#{node[:cc_rails_portal][:name]}' -D #{node[:cc_rails_portal][:theme]} -u root -p '' -t #{node[:cc_rails_portal][:theme]} -y -q -f"
end

execute "initialize-xportal-database" do
  user node[:cc_rails_portal][:user]
  cwd node[:cc_rails_portal][:root]
  environment ({'RAILS_ENV' => node[:rails][:environment]})
  command "rake db:migrate:reset"
end

if node[:cc_rails_portal][:checkout] == "true"
  execute "portal-setup" do
    user node[:cc_rails_portal][:user]
    cwd node[:cc_rails_portal][:root]
    command "rake app:setup:new_app"
  end
end
