module PludoniRspec::SystemTestChromeHelper
  def console_logs
    page.driver.browser.manage.logs.get(:browser)
  end

  def drop_in_dropzone(file_path)
    # Generate a fake input selector
    page.execute_script <<-JS
    fakeFileInput = window.$('<input/>').attr(
      {id: 'fakeFileInput', type:'file'}
    ).appendTo('body');
    JS
    # Attach the file to the fake input selector
    attach_file("fakeFileInput", file_path)
    # Add the file to a fileList array
    page.execute_script("var fileList = [fakeFileInput.get(0).files[0]]")
    # Trigger the fake drop event
    page.execute_script <<-JS
    var e = jQuery.Event('drop', { dataTransfer : { files : [fakeFileInput.get(0).files[0]] } });
    $('.uploader-action')[0].dropzone.listeners[0].events.drop(e);
    JS
  end

  def screenshot(path = '1')
    page.save_screenshot(Rails.root.join("public/screenshots/#{path}.png"), full: true)
  end

  # skip any confirm: "Really delete?"
  def skip_confirm(page)
    page.evaluate_script('window.confirm = function() { return true; }')
  end

  def in_browser(name)
    old_session = Capybara.session_name
    Capybara.session_name = name
    yield
    Capybara.session_name = old_session
  end

  # wait_until { page.has_content?("Something") }
  def wait_until(timeout = 10, &blk)
    end_time       = Time.zone.now + timeout
    last_exception = nil

    until Time.zone.now >= end_time
      begin
        result = yield
        return result if result
      rescue RSpec::Expectations::ExpectationNotMetError => ex
        last_exception = ex
      end

      sleep 0.01
    end

    msg = "timed out after #{timeout} seconds"
    msg << ":\n#{last_exception.message}" if last_exception

    raise msg
  end

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
