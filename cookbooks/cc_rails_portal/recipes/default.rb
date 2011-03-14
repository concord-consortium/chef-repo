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

if node[:cc_rails_portal][:checkout] == "true"
  execute "clone-portal-app" do
    cwd "/tmp"
    command "git clone #{node[:cc_rails_portal][:source_url]} portal"
  end

  execute "rename-portal-app" do
    cwd "/tmp"
    command "mv portal #{node[:cc_rails_portal][:root]}"
  end

  execute "bundle-install" do
    cwd node[:cc_rails_portal][:root]
    command "git checkout #{node[:cc_rails_portal][:source_branch]}"
  end
end

execute "bundle-install" do
  cwd node[:cc_rails_portal][:root]
  command "bundle install"
end

execute "setup-xportal-app" do
  cwd node[:cc_rails_portal][:root]
  command "ruby config/setup.rb -n '#{node[:cc_rails_portal][:name]}' -D #{node[:cc_rails_portal][:theme]} -u root -p '' -t #{node[:cc_rails_portal][:theme]} -y -q -f"
end

execute "initialize-xportal-database" do
  cwd node[:cc_rails_portal][:root]
  environment ({'RAILS_ENV' => 'production'})
  command "rake db:migrate:reset"
end
