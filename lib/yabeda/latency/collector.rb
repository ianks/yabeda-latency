# frozen_string_literal: true

module Yabeda
  module Latency
    LATENCY_BUCKETS = [0.0025, 0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5].freeze
    EMPTY_HASH = {}.freeze
    REQUEST_START_HEADER = 'HTTP_X_REQUEST_START'

    # Collector is a Rack middleware that provides meaures the latency of an
    # HTTP request based on the "X-Request-Start" header.
    #
    # By default metrics all have the prefix "http_server". Set
    # `:metrics_prefix` to something else if you like.
    class Collector
      attr_reader :app, :registry

      def initialize(app, metrics_prefix: :http_server, debug: false)
        @app = app
        @metrics_prefix = metrics_prefix
        @debug = debug

        init_request_metrics
      end

      def call(env) # :nodoc:
        now = Time.now
        observe(env, now)
        @app.call(env)
      end

      protected

      def observe(env, now)
        latency_seconds = calculate_latency_seconds(env, now)
        measure(latency_seconds) unless latency_seconds.nil?
      rescue StandardError => e
        warn "Could not observe latency (#{e.message})" if @debug
      end

      # rubocop:disable Metrics/MethodLength
      def init_request_metrics
        prefix = @metrics_prefix

        Yabeda.configure do
          group prefix do
            histogram(
              :request_latency,
              comment: 'The time for the HTTP request to reach Rack application',
              unit: :seconds,
              per: :field,
              tags: [],
              buckets: LATENCY_BUCKETS
            )
          end
        end
      end
      # rubocop:enable Metrics/MethodLength

      def metric
        @metric ||= Yabeda.__send__(@metrics_prefix).request_latency
      end

      def measure(latency_seconds)
        return if latency_seconds.negative? # sanity check

        metric.measure(EMPTY_HASH, latency_seconds)
      end

      def calculate_latency_seconds(env, now)
        raw_header_value = env[REQUEST_START_HEADER]
        request_start_timestamp_s = extract_timestamp_from_header_value(raw_header_value)

        puts "X-Request-Start: #{raw_header_value}, Now: #{now.to_f}" if @debug

        return unless request_start_timestamp_s

        now.to_f - request_start_timestamp_s
      end

      def extract_timestamp_from_header_value(value)
        return unless value

        str = case value
              when /^\s*([\d+.]+)\s*$/ then Regexp.last_match(1)
              # following regexp intentionally unanchored to handle
              # (ie ignore) leading server names
              when /t=([\d+.]+)/       then Regexp.last_match(1) # rubocop:disable Lint/DuplicateBranch
              end

        return unless str

        str.to_f
      end
    end
  end
end
