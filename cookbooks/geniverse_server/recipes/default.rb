#
# Cookbook Name:: geniverse_server
# Recipe:: default
#
# Copyright 2011, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

# set up GWT server
include_recipe "tomcat"
git node[:geniverse_server][:gwt][:root] do
  repository "git://github.com/psndcsrv/Geniverse-GWT.git"
  reference "master"
  enable_submodules true
  action :sync
  user node[:tomcat][:user]
end
# copy the war directory to the tomcat webapps folder
execute "copy-gwt-to-tomcat" do
  user node[:tomcat][:user]
  command "mv #{node[:geniverse_server][:gwt][:root]}/geniverse.war #{node[:tomcat][:webapp_dir]}/biologica.war"
  notifies :restart, resources(:service => "tomcat"), :delayed
end

# set up rails backend
include_recipe "cc_rails_app"
execute "add-rails.local-to-etc-hosts" do
  command 'echo "127.0.0.1  rails.local" >> /etc/hosts'
end
node[:cc_rails_app][:geniverse][:host_name] = "rails.local"
node[:cc_rails_app][:geniverse][:root] = node[:geniverse_server][:rails][:root]
include_recipe "cc_rails_app::geniverse"

# set up chat server
git node[:geniverse_server][:chat][:root] do
  repository "git://github.com/concord-consortium/geniverse-chat-server.git"
  reference "master"
  enable_submodules true
  action :sync
  user node[:cc_rails_app][:user]
end
# chat can't run under passenger, so we need
#  thin and assorted gems
gem_package "rack"
gem_package "sinatra"
gem_package "thin"
gem_package "eventmachine"
gem_package "em-http-request"
gem_package "json"
#  monit config for thin
include_recipe "monit"
monitrc("geniverse-chat", :template => "geniverse-chat.monit.erb", :app_root => node[:geniverse_server][:chat][:root])

# set up sproutcore server
# TODO What if we just want to do a static deploy of what's current?
gem_package "sproutcore"
git node[:geniverse_server][:sproutcore][:root] do
  repository "git://github.com/concord-consortium/Geniverse-SproutCore.git"
  reference "master"
  enable_submodules true
  action :sync
  user node[:cc_rails_app][:user]
end

bundle_install node[:geniverse_server][:sproutcore][:root] do
  # user node[:cc_rails_app][:user]
end

monitrc("geniverse-sproutcore", :template => "geniverse-sproutcore.monit.erb", :app_root => node[:geniverse_server][:sproutcore][:root])

# set up resources server w/ proxy server to all of the rest
include_recipe "apache2::mod_proxy"
include_recipe "apache2::mod_proxy_http"
web_app "resources" do
  server_name "localhost"
  cookbook "apache2"
  docroot node[:geniverse_server][:resources][:root]
  is_default true
  proxies [
    {:path => "/rails/", :remote => "http://rails.local/rails/"},
    {:path => "/chat/", :remote => "http://localhost:9292/chat/"},
    {:path => "/biologica/", :remote => "http://localhost:8080/biologica/"},
    {:path => "/portal/", :remote => "http://portal.local/portal/"},
    {:path => "/lab/", :remote => "http://localhost:4020/lab/"},
    {:path => "/static/", :remote => "http://localhost:4020/static/"},
  ]
end
# check out the resources into the resources folder...
git "#{node[:geniverse_server][:resources][:root]}/resources" do
  repository "git://github.com/concord-consortium/geniverse-resources.git"
  reference "master"
  user node[:cc_rails_app][:user]
  action :sync
end

# set up portal server
execute "add-portal.local-to-etc-hosts" do
  command 'echo "127.0.0.1  portal.local" >> /etc/hosts'
end
node[:cc_rails_app][:portal][:theme] = "geniverse"
node[:cc_rails_app][:portal][:name] = "Geniverse"
node[:cc_rails_app][:portal][:source_branch] = "geniverse-dev"
node[:cc_rails_app][:portal][:host_name] = "portal.local"
node[:cc_rails_app][:portal][:passenger_root] = ""
node[:cc_rails_app][:portal][:rails_base_uri] = "/portal"
node[:cc_rails_app][:portal][:root] = node[:geniverse_server][:portal][:root]
include_recipe "cc_rails_app::portal"
execute "symlink-portal-root" do
  cwd node[:geniverse_server][:portal][:root]
  user node[:cc_rails_app][:user]
  command "ln -s public portal"
end

