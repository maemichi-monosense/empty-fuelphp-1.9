#
# Cookbook Name:: fuelphp
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

# Git
package 'git' do
  action :install
end

# Apache

## add virtual hosts
httpd_conf_d = node['fuelphp']['httpd/conf.d']

directory "#{httpd_conf_d['path']}" do
  recursive true
  action :create
end

template "vhosts" do
  path "#{httpd_conf_d['path']}/#{httpd_conf_d['vhosts']}"
  source "vhosts.erb"
  mode '0644'
end

include_recipe 'apache2'

## start services and set to start on boot
service 'httpd' do
  provider Chef::Provider::Service::Systemd
  supports status: true, restart: true, reload: true
  action [:enable, :start]
end

# MariaDB
%w(mariadb mariadb-server).each { |p| package p }

service 'mariadb.service' do
  provider Chef::Provider::Service::Systemd
  supports status: true, restart: true, reload: true
  action [:enable, :start]
end

# PHP
# include_recipe 'yum-remi-chef::remi-php70'
%w(php php-mysql php-devel php-mbstring).each { |p| package p }

# set PHP.ini
template "php.ini" do
  path '/etc/php.ini'
  source "php.ini.erb"
  mode '0644'
  notifies :reload, 'service[httpd]'
end
=begin
file "php.ini" do
  path '/etc/php.ini'
  _file = Chef::Util::FileEdit.new(path)
  _file.search_file_replace_line('^;?\s?date.timezone', %(date.timezone = "#{node['fuelphp']['timezone']}"\n))
  _file.search_file_replace_line('^;?\s?default_charset', %(default_charset = "UTF-8"\n))
  content _file.send(:editor).lines.join
  mode '0644'
  notifies :reload, 'service[httpd]'
end
=end
# setup doc root & set to be under www group
user = 'vagrant'
www = "#{node['fuelphp']['group']['www']}"

group "#{www}" do
  action :create
  members ["#{user}", "apache"]
  append true
end

directory "#{node['fuelphp']['www']}" do
  recursive true
  mode '2775'
  owner "#{user}"
  group "#{www}"
  action :create
end

# deploy empty fuelphp v1.9
deploy "#{node['fuelphp']['deploy']}" do
  repo 'git://github.com/fuel/fuel.git'
  branch '1.9/develop'
  scm_provider Chef::Provider::Git
  user "root"
  group "#{www}"

  migrate false
  symlink_before_migrate Hash.new

  environment 'FUEL_ENV' => 'development'
  action :deploy
  # restart_command "cd #{node['fuelphp']['current']} && php composer.phar self-update && php composer.phar update"
end
