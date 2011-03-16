#
# Cookbook Name:: cc_rails_app
# Definition:: cc_rails_app
#
# Copyright 2011, The Concord Consortium

# expects
#   app = symbol of the type of app being installed: [:portal]
#   
define :cc_rails_app, :app => :portal do
  config = node[:cc_rails_app][params[:app]]
  web_app params[:name] do
    cookbook "rails"
    template "rails_app.conf.erb"
    docroot config[:root] + "/public"
    rails_env node[:rails][:environment]
    notifies :reload, resources(:service => "apache2"), :delayed
  end

  if node[:cc_rails_app][:checkout]
    git config[:root] do
      repository config[:source_url]
      reference config[:source_branch]
      enable_submodules true
      action :sync
    end

    # we have to check out as root, and then change the ownership of the source directory since
    # the source user won't have permissions to create a checkout in most places in the filesystem
    execute "change-source-ownership" do
      cwd config[:root]
      command "chown -R #{node[:cc_rails_app][:user]} #{config[:root]}"
      # only do it if chown doesn't return an error when trying to chown the files
      # some filesystems will throw an error when trying to run chown, NFS being one of them
      only_if "chown #{node[:cc_rails_app][:user]} #{config[:root]}"
    end
  end

  execute "bundle-install" do
    user node[:cc_rails_app][:user]
    cwd config[:root]
    command "bundle install"
  end

end