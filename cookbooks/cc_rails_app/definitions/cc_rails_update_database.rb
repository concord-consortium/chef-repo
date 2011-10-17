#
# Cookbook Name:: cc_rails_app
# Definition:: cc_rails_update_database
#
# Copyright 2011, The Concord Consortium

# expects
#   app = symbol of the type of app being installed: [:portal]
#
define :cc_rails_update_database, :app => :portal do
  config = node[:cc_rails_app][params[:app]]

  # some rake tasks will fail without the database settings having reconnect: true
  # force setting that while updating the database settings
  ruby_block "update-database-settings" do
    block do
      require 'yaml'

      root = config[:root]
      root = File.join(config[:root],"shared") if config[:capistrano_folders]
      dbYml = File.join(root, "config", "database.yml")
      opts = YAML.load_file(dbYml) || {:production => {}}
      opts.each do |env,h|
        h["reconnect"] = true
        if env.to_s == node[:rails][:environment].to_s
          h["host"]     = config[:mysql][:host] unless config[:mysql][:host].nil?
          h["database"] = config[:mysql][:database] unless config[:mysql][:database].nil?
          h["username"] = config[:mysql][:username] unless config[:mysql][:username].nil?
          h["password"] = config[:mysql][:password] unless config[:mysql][:password].nil?
          h["password"] = config[:mysql][:password] unless config[:mysql][:password].nil?
          h["adapter"]  = config[:mysql][:adapter] || "<% if RUBY_PLATFORM                = ~ /java/ %>jdbcmysql<% else %>mysql<% end %>"
          h["pool"]     = config[:mysql][:pool]    || "5"
        end
      end

      File.open(dbYml, "w") do |f|
        f.write(YAML.dump(opts))
      end
    end
    action :create
    # not_if do
    #   File.exists?(File.join(config[:root], "skip-provisioning"))
    # end
  end

  root = config[:root]
  root = File.join(config[:root],"current") if config[:capistrano_folders]
  execute "initialize-cc-rails-app-database" do
    user node[:cc_rails_app][:user]
    cwd root
    environment ({'RAILS_ENV' => node[:rails][:environment]})
    command "bundle exec rake db:migrate:reset"
    not_if do
      File.exists?(File.join(config[:root], "skip-provisioning"))
    end
  end
end
