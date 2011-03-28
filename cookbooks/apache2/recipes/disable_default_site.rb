execute "disable-default-site" do
  command "a2dissite default"
  notifies :reload, resources(:service => "apache2"), :delayed
  only_if {File.exists?(File.join(node[:apache][:dir], "sites-enabled", "000-default")) || File.exists?(File.join(node[:apache][:dir], "sites-enabled", "default"))}
end
