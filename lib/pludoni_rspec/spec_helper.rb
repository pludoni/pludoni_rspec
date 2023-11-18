RSpec.configure do |config|
  config.example_status_persistence_file_path = 'tmp/rspec.failed.txt'
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.include RSpec::Rails::RequestExampleGroup, type: :request, file_path: /spec\/api/
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
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
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
    time = 10 unless time.kind_of?(Numeric)
    Timeout.timeout(time) do
      example.run
    end
  end
end
