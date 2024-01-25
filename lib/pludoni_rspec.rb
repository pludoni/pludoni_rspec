require "pludoni_rspec/version"
require 'json'

module PludoniRspec
  class Config
    class << self
      attr_accessor :destroy_headless, :wrap_js_spec_in_headless, :chrome_arguments, :capybara_timeout, :coverage_enabled
    end
    # self.chrome_driver_version = "2.36"
    self.destroy_headless = false
    self.wrap_js_spec_in_headless = RbConfig::CONFIG['host_os']['linux']
    # self.chrome_arguments = ['headless', 'disable-gpu', "window-size=1600,1200", 'no-sandbox', 'disable-dev-shm-usage', 'lang=de']
    self.capybara_timeout = ENV['CI'] == '1' ? 30 : 5
    self.coverage_enabled = true
  end

  def self.run
    ENV["RAILS_ENV"] ||= 'test'
    coverage! if Config.coverage_enabled
    require 'pry'
    require File.expand_path("config/environment", Dir.pwd)
    abort("The Rails environment is running in production mode!") if Rails.env.production?
    require 'rspec/rails'
    require 'pludoni_rspec/spec_helper'
    require 'pludoni_rspec/cuprite'
    require 'pludoni_rspec/freeze_time'
    require 'pludoni_rspec/shared_context'
    require 'pludoni_rspec/formatter'
    RSpec.configuration.default_formatter = 'EnhancedDocumentationFormatter'
    if defined?(VCR)
      require 'pludoni_rspec/vcr'
    end
    if defined?(Devise)
      require 'pludoni_rspec/devise'
    end
    Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }
    ActiveRecord::Migration.maintain_test_schema!
  end

  def self.coverage!
    if File.exist?('coverage/.resultset.json') && (
        File.ctime('coverage/.resultset.json') < (Time.now - 900) ||
        (JSON.parse(File.read('coverage/.resultset.json')).keys.length > 4)
      )
      File.unlink('coverage/.resultset.json')
      if File.exist?('coverage/.resultset.json.lock')
        File.unlink('coverage/.resultset.json.lock')
      end
    end
    require 'simplecov'
    SimpleCov.command_name "spec:#{Time.now.to_i}"
    if ENV['CI']
      require 'simplecov-cobertura'
      SimpleCov.formatter = SimpleCov::Formatter::CoberturaFormatter
    end
    SimpleCov.start 'rails' do
      add_filter do |source_file|
        source_file.lines.count < 10
      end
      add_group "Long files" do |src_file|
        src_file.lines.count > 150
      end
    end
  end
end
