require 'prometheus/client'

class Metrics

  attr_reader :prometheus_registry

  def initialize
    @prometheus_registry = Prometheus::Client.registry
    register_metrics
  end

  def register_metrics
    %w[primo_errors argument_errors].each do |metric|
      @prometheus_registry.register(send(metric))
    end
  end

  def primo_errors
    @primo_errors ||= new_counter(:pushtocite_primo_errors_total, 'A counter of unprocessible entity errors')
  end

  def argument_errors
    @argument_errors ||= new_counter(:pushtocite_argument_errors_total, 'A counter of bad request errors')
  end

 private

  def new_counter(name, msg)
    Prometheus::Client::Counter.new(
      name.to_sym,
      msg.to_s
    )
  end
end
