# frozen_string_literal: true

module Yabeda
  module Latency
    RSpec.describe Collector do
      subject(:middleware) do
        described_class.new(app, metrics_prefix: :rack_http)
      end

      let(:app) { double(call: true) }

      after do
        Yabeda.rack_http.request_latency.sums.clear # This is a hack
      end

      context 'when there is a X-Request-Start header' do
        it 'measures request latency' do
          env = { 'HTTP_X_REQUEST_START' => "t=#{Time.now.to_f - 0.1}" }
          middleware.call(env)

          expect(Yabeda.rack_http_request_latency.sums).to match(
            {} => (be > 0.1).and(be < 1.0)
          )
        end

        it 'skips measuring if the latency is negative' do
          env = { 'HTTP_X_REQUEST_START' => "t=#{Time.now.to_f + 10_000}" }
          middleware.call(env)

          expect(Yabeda.rack_http_request_latency.sums).to match({})
        end

        it 'calls the app' do
          env = { 'HTTP_X_REQUEST_START' => "t=#{(Time.now.to_f).round(2) - 0.1}" }
          middleware.call(env)

          expect(app).to have_received(:call).with(env)
        end
      end

      context 'when there is not a X-Request-Start header' do
        it 'calls the app' do
          env = {}
          middleware.call(env)

          expect(Yabeda.rack_http_request_latency.sums).to match({})
          expect(app).to have_received(:call).with(env)
        end
      end
    end
  end
end
