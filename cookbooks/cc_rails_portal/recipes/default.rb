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
end

if node[:cc_rails_portal][:checkout]
  git node[:cc_rails_portal][:root] do
    repository node[:cc_rails_portal][:source_url]
    reference node[:cc_rails_portal][:source_branch]
    enable_submodules true
    action :sync
  end

  # we have to check out as root, and then change the ownership of the source directory since
  # the source user won't have permissions to create a checkout in most places in the filesystem
  execute "change-source-ownership" do
    cwd node[:cc_rails_portal][:root]
    command "chown -R #{node[:cc_rails_portal][:user]} #{node[:cc_rails_portal][:root]}"
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

if node[:cc_rails_portal][:checkout]
  # rake app:setup:new_app will fail without the database settings having reconnect: true
  # force setting that
  ruby_block "update-database-settings" do
    block do
      require 'yaml'

      dbYml = File.join(node[:cc_rails_portal][:root], "config", "database.yml")
      opts = YAML.load_file(dbYml)
      opts.each do |env,h|
        h["reconnect"] = true
      end

      File.open(dbYml, "w") do |f|
        f.write(YAML.dump(opts))
      end
    end
    action :create
  end

  execute "portal-setup" do
    user node[:cc_rails_portal][:user]
    cwd node[:cc_rails_portal][:root]
    environment ({'RAILS_ENV' => node[:rails][:environment]})
    command "yes | rake app:setup:new_app"
  end
end
