#
# Cookbook Name:: fuelphp
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

%w(apache2 php git).each { |recipe| include_recipe recipe }

# start services and set to start on boot
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
%w(php-mysql php-devel php-mbstring).each { |p| package p }

# set PHP.ini
template "php.ini" do
  path '/etc/php.ini'
  source "php.ini.erb"
  mode '0644'
  notifies :reload, 'service[httpd]'
end

# setup doc root & set to be under www group
user = 'vagrant'
www = "#{node['fuelphp']['group']['www']}"

group "#{www}" do
  action :create
  members "#{user}"
  append true
end

directory "#{node['fuelphp']['www']}" do
  recursive true
  mode '2775'
  owner "#{user}"
  group "#{www}"
  action :create
end

doc_root = "#{node['fuelphp']['doc_root']}"

directory "#{doc_root}" do
  recursive true
  action :create
end

# add virtual hosts
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

html = node['fuelphp']['html']

# deploy empty fuelphp v1.9
deploy "#{html}" do
  repo 'git://github.com/fuel/fuel.git'
  revision 'refs/heads/1.9/develop'

  environment 'FUEL_ENV' => 'development'
  action :deploy
  restart_command "cd #{html} && php composer.phar update"

  scm_provider Chef::Provider::Git
end
