# # encoding: utf-8

# Inspec test for recipe Task5::default

# The Inspec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec_reference.html

require 'serverspec'

set :backend, :cmd
set :os, family: 'windows'

# Git package
describe package('Git version 2.10.0') do
  it { should be_installed }
end

# IIS installed
describe windows_feature('Web-WebServer') do
  it { should be_installed.by('powershell') }
end

# IIS started
describe port(80) do
  it { should be_listening }
end

# Repo cloned
describe file('C:/inetpub/wwwroot/.git') do
  it { should exist }
  it { should be_directory }
end

# Repo pulling script exists
describe file('C:/.task6/pull_repo.ps1') do
  it { should exist }
  it { should contain('net start w3svc') }
end
