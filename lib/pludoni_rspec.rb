require "pludoni_rspec/version"
require 'json'

# rubocop:disable Rails/FilePath
module PludoniRspec
  class Config
    class << self
      attr_accessor :chrome_driver_version
      attr_accessor :destroy_headless
      attr_accessor :wrap_js_spec_in_headless
      attr_accessor :chrome_arguments
      attr_accessor :capybara_timeout
      attr_accessor :capybara_driver
      attr_accessor :firefox_arguments
      attr_accessor :apparition_arguments
    end
    # self.chrome_driver_version = "2.36"
    self.destroy_headless = false
    self.wrap_js_spec_in_headless = RbConfig::CONFIG['host_os']['linux']
    # self.chrome_arguments = ['headless', 'disable-gpu', "window-size=1600,1200", 'no-sandbox', 'disable-dev-shm-usage', 'lang=de']
    self.capybara_timeout = ENV['CI'] == '1' ? 30 : 5
    self.firefox_arguments = ['--headless', '--window-size=1600,1200']
    self.apparition_arguments = {
      js_errors: false,
      screen_size: [1600, 1200],
      window_size: [1600, 1200],
      browser_logger: File.open(File::NULL, 'w'),
    }
    if ENV['CI']
      self.apparition_arguments[:browser_options] = { 'no-sandbox' => true }
    end
    self.capybara_driver = :apparition
  end
  def self.run
    ENV["RAILS_ENV"] ||= 'test'
    coverage!
    require 'pry'
    require File.expand_path("config/environment", Dir.pwd)
    abort("The Rails environment is running in production mode!") if Rails.env.production?
    require 'rspec/rails'

    require 'pludoni_rspec/spec_helper'
    if PludoniRspec::Config.capybara_driver == :apparition
      require 'pludoni_rspec/apparition'
    else
      require 'pludoni_rspec/capybara'
    end
    require 'pludoni_rspec/freeze_time'
    require 'pludoni_rspec/shared_context'
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
