#
# Cookbook Name:: fuelphp
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

# PHP
%w(php-mysql php-devel php-mbstring).each { |p| package p }

# start services and set to start on boot
%w(httpd mysqld).each do |srv|
  service srv do
    supports status: true, restart: true, reload: true
    action [:enable, :start]
  end
end

# setup doc root & set to be under www group
user = 'ec2-user'
name = "#{node['fuelphp']['group']['name']}"

group "#{name}" do
  action :create
  members "#{user}"
  append true
end

www = "#{node['fuelphp']['www']}"

directory "#{www}" do
  recursive true
  mode '2775'
  owner "#{user}"
  group "#{name}"
  action :create
end

doc_root = "#{node['fuelphp']['doc_root']}"

directory "#{doc_root}" do
  recursive true
  action :create
end

index = "#{node['fuelphp']['doc_root']}#{node['fuelphp']['index']}"

cookbook_file "#{index}" do
  mode '0664'
  source "#{node['fuelphp']['index']}"
  owner "#{user}"
  group "#{name}"
  action :create_if_missing
end

# add virtual hosts
httpd_conf_d = node['fuelphp']['httpd/conf.d']

template "vhosts" do
  path "#{httpd_conf_d['path']}#{httpd_conf_d['vhosts']}"
  source "vhosts.erb"
  mode '0644'
end

# set PHP.ini
template "php.ini" do
  path '/etc/php.ini'
  source "php.ini.erb"
  mode '0644'
  notifies :reload, 'service[httpd]'
end
