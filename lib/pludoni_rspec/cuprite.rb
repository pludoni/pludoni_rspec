require "capybara"
require 'capybara/cuprite'
require "headless"
require "puma"
require 'pludoni_rspec/system_test_chrome_helper'

Capybara.register_driver(:cuprite_pl) do |app|
  options = {}
  if ENV['CI']
    options['no-sandbox'] = nil
  end
  options['disable-smooth-scrolling'] = true
  Capybara::Cuprite::Driver.new(app,
    window_size: [1200, 800],
    browser_options: options,
    js_errors: true,
    env: { "LD_PRELOAD" => "" },
    timeout: 20,
    process_timeout: 15,
    inspector: ENV['INSPECTOR']
  )
end
Capybara.javascript_driver = :cuprite_pl
Capybara.current_driver = :cuprite_pl

RSpec.configure do |c|
  c.include PludoniRspec::SystemTestChromeHelper, type: :feature
  c.include PludoniRspec::SystemTestChromeHelper, type: :system
  c.before(:all, js: true) do
    # disable puma output
    Capybara.server = :puma, { Silent: true }
  end
  c.before(:each, type: :system) do
    if defined?(driven_by)
      driven_by :cuprite_pl
    end
  end
  c.around(:example, js: true) do |ex|
    begin
      if !@headless and PludoniRspec::Config.wrap_js_spec_in_headless
        @headless = Headless.new(destroy_at_exit: true, reuse: true)
        @headless.start
      end
      ex.run
    ensure
      if @headless and PludoniRspec::Config.destroy_headless
        @headless.destroy
      end
    end
  end
end
Capybara.default_max_wait_time = PludoniRspec::Config.capybara_timeout
