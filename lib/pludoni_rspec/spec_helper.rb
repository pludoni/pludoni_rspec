RSpec.configure do |config|
  config.before(:each) do
    ActiveSupport::CurrentAttributes.reset_all if defined?(ActiveSupport::CurrentAttributes)
  end
  config.example_status_persistence_file_path = 'tmp/rspec.failed.txt'
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.include RSpec::Rails::RequestExampleGroup, type: :request, file_path: %r{spec/api}
  config.before do
    I18n.locale = I18n.default_locale
    if defined?(Fabrication)
      if Fabrication::Sequencer.respond_to?(:clear)
        Fabrication::Sequencer.clear
      else
        Fabrication::Sequencer.reset
      end
    end
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.bisect_runner = :shell
  config.order = :defined
  if config.respond_to?(:fixture_paths)
    config.fixture_paths ||= []
    config.fixture_paths << "#{::Rails.root}/spec/fixtures"
  else
    config.fixture_path = "#{::Rails.root}/spec/fixtures"
  end
  config.infer_spec_type_from_file_location!
  config.use_transactional_fixtures = true
  if defined?(ActionMailer::Base)
    config.before(:each) do
      ActionMailer::Base.deliveries.clear
    end
  end
  config.filter_rails_from_backtrace!
  config.filter_gems_from_backtrace("fabrication")
  config.filter_gems_from_backtrace("grape")
  config.filter_gems_from_backtrace("rack")
  if defined?(ViewComponent)
    config.include ViewComponent::TestHelpers, type: :component
    config.include Capybara::RSpecMatchers, type: :component
  end
  if defined?(ViteRuby)
    # rubocop:disable Style/GlobalVars
    config.before(:each, type: :system) do
      unless $vite_build
        puts "\e[31mPrecompiling Vite for system specs \e[0m"
        bm = Benchmark.measure do
          ViteRuby.commands.build
        end
        $vite_build = true
        puts "\e[32m -> Vite build done in #{bm.real.round(2)} \e[0m"
      end
    end
  end

  config.around(:each, :timeout) do |example|
    time = 10 unless time.is_a?(Numeric)
    Timeout.timeout(time) do
      example.run
    end
  end

  # helper method for below
  def current_file_is_the_only_spec?
    file = caller.find { |c| c =~ /_spec\.rb/ }.split(':').first
    file = Pathname.new(file).relative_path_from(Rails.root).to_s
    ARGV.any? { |arg| arg.include?(file) }
  end

  # skip this example, only run if you are working on it and skip it later
  #   like special customers bugs etc.
  def only_run_when_single_spec_and_local!
    if ENV['CI'] || !current_file_is_the_only_spec?
      skip "Only run when run as a single spec and not CI set"
    end
  end

  # For System specs:
  # prints the instructions to open the current page in your local browser
  # if you run the specs remotely, create a SSH tunnel to the server during system specs
  # and open the brOwser on your local machine
  def local!
    uri = URI.parse(page.current_url)
    puts "--- Connect with local browser:"
    puts "  1. Open a SSH tunnel with port forwarding to the test server:"
    puts "\nssh #{ENV['LOGNAME']}@pludoni.com -L 8080:localhost:#{uri.port}\n"
      puts "  2. Open in Browser: "
    uri.port = nil
    uri.scheme = nil
    uri.host = nil
    puts "\nhttp://localhost:8080#{uri}\n"
    puts "  Afterwards, you can close the SSH session"
  end

end
