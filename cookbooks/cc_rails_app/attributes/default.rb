default[:cc_rails_app][:user] = "cc"
default[:cc_rails_app][:checkout] = true

# portal specific defaults
default[:cc_rails_app][:portal][:theme] = "xproject"
default[:cc_rails_app][:portal][:name] = "Cross Project Portal"
default[:cc_rails_app][:portal][:source_url] = "git://github.com/stepheneb/rigse.git"
default[:cc_rails_app][:portal][:source_branch] = "xproject-dev"
default[:cc_rails_app][:portal][:root] = "/web/portal"
default[:cc_rails_app][:portal][:host_name] = nil

# geniverse specific defaults
default[:cc_rails_app][:geniverse][:source_url] = "git://github.com/concord-consortium/geniverse-rails-server.git"
default[:cc_rails_app][:geniverse][:source_branch] = "master"
default[:cc_rails_app][:geniverse][:root] = "/web/geniverse.rails"
default[:cc_rails_app][:geniverse][:host_name] = nil

[:portal].each do |app|
  # override these if you need to customize the database settings
  default[:cc_rails_app][app][:mysql][:host] = nil
  default[:cc_rails_app][app][:mysql][:database] = nil
  default[:cc_rails_app][app][:mysql][:username] = nil
  default[:cc_rails_app][app][:mysql][:password] = nil
end
