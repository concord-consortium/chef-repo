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

      dbYml = File.join(config[:root], "config", "database.yml")
      opts = YAML.load_file(dbYml)
      opts.each do |env,h|
        h["reconnect"] = true
        if env.to_s == node[:rails][:environment].to_s
          h["host"] = config[:mysql][:host] unless config[:mysql][:host].nil?
          h["database"] = config[:mysql][:database] unless config[:mysql][:database].nil?
          h["username"] = config[:mysql][:username] unless config[:mysql][:username].nil?
          h["password"] = config[:mysql][:password] unless config[:mysql][:password].nil?
        end
      end

      File.open(dbYml, "w") do |f|
        f.write(YAML.dump(opts))
      end
    end
    action :create
  end

  execute "initialize-cc-rails-app-database" do
    user node[:cc_rails_portal][:user]
    cwd config[:root]
    environment ({'RAILS_ENV' => node[:rails][:environment]})
    command "rake db:migrate:reset"
  end
end
