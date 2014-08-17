require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require 'bundler/setup'
Bundler.setup

require 'rakali'

RSpec.configure do |config|
  config.before do
    ARGV.replace []
  end

  def fixture_path
    File.expand_path("../fixtures", __FILE__) + '/'
  end

  # This code was adapted from Thor, available under MIT-LICENSE
  # Copyright (c) 2008 Yehuda Katz, Eric Hodel, et al.
  def capture(stream)
    begin
      stream = stream.to_s
      eval "$#{stream} = StringIO.new"
      yield
      result = eval("$#{stream}").string
    ensure
      eval("$#{stream} = #{stream.upcase}")
    end

    result
  end

  def capture_stdout(&block)
    original_stdout = $stdout
    $stdout = fake = StringIO.new
    begin
      yield
    ensure
      $stdout = original_stdout
    end
    fake.string
  end

  def capture_stderr(&block)
    original_stderr = $stderr
    $stderr = fake = StringIO.new
    begin
      yield
    ensure
      $stderr = original_stderr
    end
    fake.string
  end

  # This code was adapted from Ruby on Rails, available under MIT-LICENSE
  # Copyright (c) 2004-2013 David Heinemeier Hansson
  def silence_warnings
    old_verbose, $VERBOSE = $VERBOSE, nil
    yield
  ensure
    $VERBOSE = old_verbose
  end

  alias silence capture
end
