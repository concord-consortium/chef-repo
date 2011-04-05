#
# Cookbook Name:: cc_rails_app
# Definition:: cc_rails_app
#
# Copyright 2011, The Concord Consortium

# expects:
#   app = symbol of the type of app being installed: [:portal, :geniverse, etc.]
#   rails_base_uri = the path that passenger should serve this rails app from
#
define :cc_rails_app, :app => :portal do
  config = node[:cc_rails_app][params[:app]]
  web_app params[:name] do
    cookbook "rails"
    template "rails_app.conf.erb"
    server_name config[:host_name]
    docroot "#{config[:root]}#{config[:capistrano_folders] ? "/current" : ""}#{config[:passenger_root]}"
    rails_env node[:rails][:environment]
    rails_base_uri config[:rails_base_uri]
    proxies config[:proxies]
    extra_config config[:extra_config]
    notifies :reload, resources(:service => "apache2"), :delayed
  end

  if node[:cc_rails_app][:checkout]
    if config[:capistrano_folders]
      cap_setup config[:root] do
      end
      deploy config[:root] do
        repo config[:source_url]
        branch config[:source_branch]
        enable_submodules true
        migrate false
        action :deploy
        restart_command "touch tmp/restart.txt"
        symlink_before_migrate({
          "config/database.yml" => "config/database.yml",
          "config/settings.yml" => "config/settings.yml",
          "config/installer.yml" => "config/installer.yml",
          "config/mailer.yml" => "config/mailer.yml",
          "config/rinet_data.yml" => "config/rinet_data.yml",
          "config/newrelic.yml" => "config/newrelic.yml",
          "config/initializers/site_keys.rb" => "config/initializers/site_keys.rb",
          "config/initializers/subdirectory.rb" => "config/initializers/subdirectory.rb",
          "public/otrunk-examples" => "public/otrunk-examples",
          "public/sparks-content" => "public/sparks-content",
          "public/installers" => "public/installers",
          "config/nces_data" => "config/nces_data",
          "rinet_data" => "rinet_data",
          "system" => "public/system"
        })
        not_if do
          File.exists?(File.join(config[:root], "skip-provisioning"))
        end
      end
    else
      git config[:root] do
        repository config[:source_url]
        reference config[:source_branch]
        enable_submodules true
        action :sync
        not_if do
          File.exists?(File.join(config[:root], "skip-provisioning"))
        end
      end
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

  root = config[:root]
  root = File.join(root, "current") if config[:capistrano_folders]
  remote_file "#{root}/Gemfile" do
    source config[:gemfile]
    action :create_if_missing
  end

  bundle_install root do
    # user node[:cc_rails_app][:user]
  end
end
