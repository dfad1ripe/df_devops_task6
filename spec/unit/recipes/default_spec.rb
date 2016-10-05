#
# Cookbook Name:: Task5
# Spec:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

require 'spec_helper.rb'

describe 'Task6::default' do
  context 'test:' do
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'windows', version: '2012r2')
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'installs "Git"' do
      expect(chef_run).to install_windows_package('Git version 2.10.0')
    end

    it 'installs IIS' do
      expect(chef_run).to install_windows_feature('IIS-WebServerRole')
      expect(chef_run).to install_windows_feature('IIS-WebServer')
    end

    it 'starts IIS' do
      expect(chef_run).to start_windows_service('W3SVC')
    end

    it 'adds a repo script' do
      expect(chef_run).to create_template('C:/.task6/pull_repo.ps1')
    end
  end
end
