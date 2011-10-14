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

config = node[:cc_rails_app][:portal]
root = config[:root]
root = File.join(root,"current") if config[:capistrano_folders]



if node[:cc_rails_app][:setup]

  # run the config setup script
  # TODO: this probably needs to be reworked
  # so that it functions with more recent versions
  execute "setup-portal-settings" do
    user node[:cc_rails_app][:user]
    cwd root
    command "ruby config/setup.rb -n '#{config[:name]}' -D #{config[:theme]} -u #{config[:mysql][:username]} -p '#{config[:mysql][:password]}' -t #{config[:theme]} -y -q -f"
    not_if do
      File.exists?(File.join(config[:root], "skip-provisioning"))
    end
  end

  # intialize the database
  cc_rails_update_database "portal" do
    app :portal
  end
  
  # run rake setup task
  execute "portal-setup" do
    user node[:cc_rails_app][:user]
    cwd root
    environment ({'RAILS_ENV' => node[:rails][:environment]})
    command "yes | rake app:setup:new_app"
    not_if do
      File.exists?(File.join(config[:root], "skip-provisioning"))
    end
  end

  # FIXME This should get done, but for some reason, tends to make chef hang...
  # execute "compile-sass" do
  #   user node[:cc_rails_app][:user]
  #   cwd root
  #   environment ({'RAILS_ENV' => node[:rails][:environment]})
  #   command "compass --sass-dir public/stylesheets/sass/ --css-dir public/stylesheets/ -s compressed --force"
  # end

  # execute "package-assets" do
  #   user node[:cc_rails_app][:user]
  #   cwd root
  #   environment ({'RAILS_ENV' => node[:rails][:environment]})
  #   command "rake asset:packager:build_all"
  # end
end

file File.join(config[:root], "skip-provisioning") do
  action :touch
end
