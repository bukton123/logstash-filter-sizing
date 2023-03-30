# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"

# This example filter will replace the contents of the default
# message field with whatever you specify in the configuration.
#
# Setting the config_name here is required. This is how you
# configure this filter from your Logstash config.
#
# filter {
#   sizing {
#     group => [ "message" ]
#   }
# }
#
class LogStash::Filters::Event < LogStash::Filters::Base
  config_name "sizing"

  # syntax: `group => [ "name of event", "name of event" ]`
  config :group, :validate => :array, :default => []

  # syntax: `ignore => [ "name of event" ]`
  # The ignore, when ignore output field
  config :group_ignore, :validate => :array, :default => []

  # The flush interval, when the metrics event is created. Must be a multiple of 1s.
  config :flush_interval, :validate => :number, :default => 30

  # The clear interval, when all counter are reset.
  #
  # If set to -1, the default value, the metrics will never be cleared.
  # Otherwise, should be a multiple of 1s.
  config :clear_interval, :validate => :number, :default => 30

  public
  def register
    require "metriks"
    require "socket"
    require "atomic"
    require "thread_safe"
    require "knjrbfw"

    @last_flush = Atomic.new(0) # how many seconds ago the metrics where flushed.
    @last_clear = Atomic.new(0) # how many seconds ago the metrics where cleared.
    @host = Socket.gethostname.force_encoding(Encoding::UTF_8)
    @sizing_groups = ThreadSafe::Cache.new { |h,k| h[k] = Metriks.meter k }
  end

  public
  def filter(event)
    key = create_key event
    puts event.class
    # analyzer = Knj::Memory_analyzer::Object_size_counter.new(event)
    # puts analyzer
    # @sizing_groups[key].mark analyzer.calculate_size
  end

  def flush(options = {})
    # Add 1 seconds to @last_flush and @last_clear counters
    # since this method is called every 1 seconds.
    @last_flush.update { |v| v + 5 }
    @last_clear.update { |v| v + 5 }

    # Do nothing if there's nothing to do ;)
    return unless should_flush?

    event = LogStash::Event.new
    event.set("message", @host)
    results = []
    @sizing_groups.each_pair do |name, metric|
      flush_rates name, metric, results
      metric.clear if should_clear?
    end

    event.set("events", results)


    # Reset counter since metrics were flushed
    @last_flush.value = 0

    if should_clear?
      #Reset counter since metrics were cleared
      @last_clear.value = 0
      @sizing_groups.clear
    end

    filter_matched(event)
    return [event]
  end

  def periodic_flush
    true
  end

  private

  def create_key(event)
    key_events = []
    @group.each do |g|
      key_events << "#{g}:#{event.get(event.sprintf(g))}"
    end

    key_events.join(",")
  end

  def flush_rates(name, metric, results)
    hashMap = {
      event: metric.count
    }

    name.split(",", -1).each do |kv|
      output = kv.split(":", -1)
      hashMap[output[0]] = output[1] || ""
    end

    results << hashMap
  end

  def should_flush?
    @last_flush.value >= @flush_interval && !@sizing_groups.empty?
  end

  def should_clear?
    @clear_interval > 0 && @last_clear.value >= @clear_interval
  end

end # class LogStash::Filters::Event
