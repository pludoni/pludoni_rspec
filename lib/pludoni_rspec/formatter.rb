require 'rspec/core'
require 'rspec/core/formatters/documentation_formatter'

class EnhancedDocumentationFormatter < RSpec::Core::Formatters::DocumentationFormatter
  RSpec::Core::Formatters.register self, :example_group_started, :example_group_finished,
    :example_passed, :example_pending, :example_failed

  class << self
    attr_accessor :threshold_for_good, :threshold_for_bad
  end
  self.threshold_for_good = 0.2
  self.threshold_for_bad = 2

  def example_group_started(notification)
    output.puts if @group_level == 0
    filename = if @group_level == 0
                 RSpec::Core::Formatters::ConsoleCodes.wrap(notification.group.file_path, :gray)
               end
    output.puts "#{current_indentation}#{notification.group.description.strip} #{filename}"

    @group_level += 1
  end

  private

  def passed_output(example)
    super + "  " + duration(example)
  end

  def failure_output(example)
    super + "  " + duration(example)
  end

  def pending_output(example, message)
    super + "  " + duration(example)
  end

  def duration(example)
    time = example.metadata[:execution_result][:run_time]
    if time < self.class.threshold_for_good
      RSpec::Core::Formatters::ConsoleCodes.wrap("#{(time * 1000).round}ms", :black)
    elsif time > self.class.threshold_for_bad
      RSpec::Core::Formatters::ConsoleCodes.wrap("#{time.round(2)}s", :red)
    else
      RSpec::Core::Formatters::ConsoleCodes.wrap("#{time.round(2)}s", :yellow)
    end
  end
end
