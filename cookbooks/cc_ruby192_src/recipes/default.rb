# Cookbook Name:: cc_ruby192_src
# Recipe:: default
#
# Copyright 2011, Concord Consortium
#
# All rights reserved

# TODO: This is really weak.  It's super non-portable

# TODO: Make this patch-level settable
patch_level     = '290'
src_dir   = "/usr/local/src"
ruby_ver  = "ruby-1.9.2-p#{patch_level}"
ruby_dir  = "#{src_dir}/#{ruby_ver}"
tar_file  = "#{ruby_dir}.tar.gz"
remote_tar_file = "http://ftp.ruby-lang.org/pub/ruby/1.9/#{ruby_ver}.tar.gz"


remote_file tar_file do
  source remote_tar_file
  mode "0644"
  # later we want to put the hash here.
  # checksum "08da002l" # A SHA256 (or portion thereof) of the file.
end

execute 'install_libyml' do
# TODO: make this use 'package' and behave x-platform
  command "sudo yum install libyaml-devel.i386 -y -q --enablerepo=epel"
end

execute 'install_libyml' do
# TODO: make this use 'package' and behave  x-platform
  command "sudo yum install libffi-devel -y -q --enablerepo=epel"
end

execute 'unpack_tarfile' do
  cwd src_dir
  command "tar -zxvf #{tar_file}"
end

execute 'configure_ruby' do
  cwd ruby_dir
  command "./configure --prefix=/usr/local"
end

execute 'build_ruby' do
  cwd ruby_dir
  command "make"
end

execute 'install_ruby' do
  cwd ruby_dir
  command "make install"
end


