#
# Cookbook Name:: cc_rails_app
# Recipe:: portal
#
# Copyright 2011, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "cc_rails_app::default"

cc_rails_app "geniverse" do
  app :geniverse
  rails_base_uri "/rails"
end

execute "geniverse-rails-setup" do
  user node[:cc_rails_app][:user]
  cwd File.join(node[:cc_rails_app][:geniverse][:root], "Geniverse-SproutCore", "rails", "geniverse")
  environment ({'RAILS_ENV' => node[:rails][:environment]})
  command "rake db:reset"
end
