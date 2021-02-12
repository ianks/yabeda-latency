# frozen_string_literal: true

require 'bundler/setup'
require 'yabeda/latency'
require 'pry'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:all) do
    Yabeda.configure!
  end
end

# Add sum of all observed values to histograms to check in tests
module SummingHistogram
  def measure(tags, value)
    all_tags = ::Yabeda::Tags.build(tags)
    sums[all_tags] += value
    super
  end

  def sums
    @sums ||= Concurrent::Hash.new { |h, k| h[k] = 0.0 }
  end
end

Yabeda::Histogram.prepend(SummingHistogram)
