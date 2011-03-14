if ENV['HOME'] && File.exist?(File.join(ENV['HOME'], '.chef', 'knife.rb'))
    Chef::Config.from_file File.join(ENV['HOME'], '.chef', 'knife.rb')
end

cookbook_path            ["#{File.dirname(__FILE__)}/../cookbooks"]
