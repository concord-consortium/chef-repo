#
# Cookbook Name:: unzip
# Recipe:: default
#
# Copyright 2011, The Concord Consortium
#
# All rights reserved - Do Not Redistribute
#

package "unzip" do
  package_name value_for_platform(
    "default" => "unzip"
  )
end
