execute "disable-default-site" do
  command "a2dissite default"
  notifies :reload, resources(:service => "apache2"), :delayed
end
