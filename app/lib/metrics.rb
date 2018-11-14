require 'prometheus/client'

class Metrics

  attr_reader :registry

  def initialize
    @registry = Prometheus::Client.registry
  end

end
