#
# Cookbook Name:: Task6
# Recipe:: default
#
# Copyright (C) 2016 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

#
# Dependencies

chef_gem 'chef-rewind' do	# to bypass CHEF-3694
  compile_time true
end
require 'chef/rewind'

#
# Install IIS

%w(IIS-WebServerRole IIS-WebServer).each do |wf|
  windows_feature wf do
    action :install
    all true
  end
end

#
# Install GIT package

git_package_url = node['Task6']['git']['package_url']
git_package_name = node['Task6']['git']['package_name']
windows_package git_package_name do
  action :install
  source git_package_url
end

#
# Enable and stop IIS
# Indeed, IIS service as it is auto-configured and auto-started
# in W2012R2. Some actions however require IIS to be stopped, so
# we force this state.

windows_service 'W3SVC' do
  action [:enable, :stop]
end

#
# Delete the contents of default IIS website if it still exists.
# Criteria: stock iis-85.png exists.
# As chef resources do not allow wildcard operation, doing that
# with regular OS command.

execute 'Cleanup stock IIS website' do
  command 'del /q "C:\inetpub\wwwroot\*"'
  action :run
  only_if { File.exist?('C:/inetpub/wwwroot/iis-85.png') }
end

#
# Create a directory where all service files will be kept.
# Initially, this was suggested to be %USERPROFILE%/.task6, however
# %USERPROFILE% dir is not created until a user logs at least once.
# One option to deal with this could be using 'windows_home' community
# cookbook to create homedir. Another - just to create it under C:\.

# Defining full path of base dir

# base = 'C:/Users/' + node['Task6']['base']['username'] +
#        '/' + node['Task6']['base']['subdir']
base = 'C:/' + node['Task6']['base']['subdir']

directory base do
  action :create
end

#
# Put batch file that clones the repo

clone_script = base + '/clone_repo.cmd'
template clone_script do
  source 'clone_repo.erb'
  action :create
end

#
# Clone the repo once for the 1st use.

execute 'Clone the repo initially' do
  command clone_script
  action :run
  not_if { File.exist?('C:/inetpub/wwwroot/.git') }
end

#
# Release resource name 'W3SVC' used previously and
# start IIS back, once all actions on the website dir are finished

unwind 'windows_service[W3SVC]'
windows_service 'W3SVC' do
  action :start
end

#
# Now putting a script that would pull the data and trigger IIS restart.

pull_script = base + '/pull_repo.ps1'
template pull_script do
  source 'pull_repo.erb'
  action :create
end

#
# This script should run once each 5 min on the target system

windows_task 'Check repo' do
  user 'Administrator'
  password 'vagrant'
  cwd base
  command 'powershell ./pull_repo.ps1'
  run_level :highest
  frequency :minute
  frequency_modifier 5
end
