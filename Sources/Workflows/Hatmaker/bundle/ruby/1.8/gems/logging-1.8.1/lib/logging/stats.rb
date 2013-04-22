# Simple statistics collection and logging module.
#
module Logging::Stats

  # A very simple little class for doing some basic fast statistics
  # sampling. You feed it either samples of numeric data you want measured
  # or you call Sampler#tick to get it to add a time delta between the last
  # time you called it. When you're done either call sum, sumsq, num, min,
  # max, mean or sd to get the information. The other option is to just
  # call to_s and see everything.
  #
  # It does all of this very fast and doesn't take up any memory since the
  # samples are not stored but instead all the values are calculated on the
  # fly.
  #
  class Sampler

    attr_reader :name, :sum, :sumsq, :num, :min, :max, :last

    # Create a new sampler.
    #
    def initialize( name )
      @name = name
      reset
    end

    # Resets the internal counters so you can start sampling again.
    #
    def reset
      @sum = 0.0
      @sumsq = 0.0
      @num = 0
      @min = 0.0
      @max = 0.0
      @last = nil
      @last_time = Time.now.to_f
      self
    end

    # Coalesce the statistics from the _other_ sampler into this one. The
    # _other_ sampler is not modified by this method.
    #
    # Coalescing the same two samplers multiple times should only be done if
    # one of the samplers is reset between calls to this method. Otherwise
    # statistics will be counted multiple times.
    #
    def coalesce( other )
      @sum += other.sum
      @sumsq += other.sumsq
      if other.num > 0
        @min = other.min if @min > other.min
        @max = other.max if @max < other.max
        @last = other.last
      end
      @num += other.num
    end

    # Adds a sampling to the calculations.
    #
    def sample( s )
      @sum += s
      @sumsq += s * s
      if @num == 0
        @min = @max = s
      else
        @min = s if @min > s
        @max = s if @max < s
      end
      @num += 1
      @last = s
    end

    # Returns statistics in a common format.
    #
    def to_s
      "[%s]: SUM=%0.6f, SUMSQ=%0.6f, NUM=%d, MEAN=%0.6f, SD=%0.6f, MIN=%0.6f, MAX=%0.6f" % to_a
    end

    # An array of the values: [name,sum,sumsq,num,mean,sd,min,max]
    #
    def to_a
      [name, sum, sumsq, num, mean, sd, min, max]
    end

    # Class method that returns the headers that a CSV file would have for the
    # values that this stats object is using.
    #
    def self.keys
      %w[name sum sumsq num mean sd min max]
    end

    def to_hash
      {:name => name, :sum => sum, :sumsq => sumsq, :num => num,
       :mean => mean, :sd => sd, :min => min, :max => max}
    end

    # Calculates and returns the mean for the data passed so far.
    #
    def mean
      return 0.0 if num < 1
      sum / num
    end

    # Calculates the standard deviation of the data so far.
    #
    def sd
      return 0.0 if num < 2

      # (sqrt( ((s).sumsq - ( (s).sum * (s).sum / (s).num)) / ((s).num-1) ))
      begin
        return Math.sqrt( (sumsq - ( sum * sum / num)) / (num-1) )
      rescue Errno::EDOM
        return 0.0
      end
    end

    # You can just call tick repeatedly if you need the delta times
    # between a set of sample periods, but many times you actually want
    # to sample how long something takes between a start/end period.
    # Call mark at the beginning and then tick at the end you'll get this
    # kind of measurement.  Don't mix mark/tick and tick sampling together
    # or the measurement will be meaningless.
    #
    def mark
      @last_time = Time.now.to_f
    end

    # Adds a time delta between now and the last time you called this.  This
    # will give you the average time between two activities.
    #
    # An example is:
    #
    #  t = Sampler.new("do_stuff")
    #  10000.times { do_stuff(); t.tick }
    #  t.dump("time")
    #
    def tick
      now = Time.now.to_f
      sample(now - @last_time)
      @last_time = now
    end
  end  # class Sampler

  # The Tracker class provides synchronized access to a collection of
  # related samplers.
  #
  class Tracker

    attr_reader :stats

    # Create a new Tracker instance. An optional boolean can be passed in to
    # change the "threadsafe" value of the tracker. By default all trackers
    # are created to be threadsafe.
    #
    def initialize( threadsafe = true )
      @stats = Hash.new do |h,name|
        h[name] = ::Logging::Stats::Sampler.new(name)
      end
      @mutex = threadsafe ? ReentrantMutex.new : nil
      @runner = nil
    end

    # Coalesce the samplers from the _other_ tracker into this one. The
    # _other_ tracker is not modified by this method.
    #
    # Coalescing the same two trackers multiple times should only be done if
    # one of the trackers is reset between calls to this method. Otherwise
    # statistics will be counted multiple times.
    #
    # Only this tracker is locked when the coalescing is happening. It is
    # left to the user to lock the other tracker if that is the desired
    # behavior. This is a deliberate choice in order to prevent deadlock
    # situations where two threads are contending on the same mutex.
    #
    def coalesce( other )
      sync {
        other.stats.each do |name,sampler|
          stats[name].coalesce(sampler)
        end
      }
    end

    # Add the given _value_ to the named _event_ sampler. The sampler will
    # be created if it does not exist.
    #
    def sample( event, value )
      sync {stats[event].sample(value)}
    end

    # Mark the named _event_ sampler. The sampler will be created if it does
    # not exist.
    #
    def mark( event )
      sync {stats[event].mark}
    end

    # Tick the named _event_ sampler. The sampler will be created if it does
    # not exist.
    #
    def tick( event )
      sync {stats[event].tick}
    end

    # Time the execution of the given block and store the results in the
    # named _event_ sampler. The sampler will be created if it does not
    # exist.
    #
    def time( event )
      sync {stats[event].mark}
      yield
    ensure
      sync {stats[event].tick}
    end

    # Reset all the samplers managed by this tracker.
    #
    def reset
      sync {stats.each_value {|sampler| sampler.reset}}
      self
    end

    # Periodically execute the given _block_ at the given _period_. The
    # tracker will be locked while the block is executing.
    #
    # This method is useful for logging statistics at given interval.
    #
    # Example
    #
    #    periodically_run( 300 ) {
    #      logger = Logging::Logger['stats']
    #      tracker.each {|sampler| logger << sampler.to_s}
    #      tracker.reset
    #    }
    #
    def periodically_run( period, &block )
      raise ArgumentError, 'a runner already exists' unless @runner.nil?

      @runner = Thread.new do
        start = stop = Time.now.to_f
        loop do
          seconds = period - (stop-start)
          seconds = period if seconds <= 0
          sleep seconds

          start = Time.now.to_f
          break if Thread.current[:stop] == true
          if @mutex then @mutex.synchronize(&block)
          else block.call end
          stop = Time.now.to_f
        end
      end
    end

    # Stop the current periodic runner if present.
    #
    def stop
      return if @runner.nil?
      @runner[:stop] = true
      @runner.wakeup if @runner.status
      @runner = nil
    end

    # call-seq:
    #    sync { block }
    #
    # Obtains an exclusive lock, runs the block, and releases the lock when
    # the block completes. This method is re-entrant so that a single thread
    # can call +sync+ multiple times without hanging the thread.
    #
    def sync
      return yield if @mutex.nil?
      @mutex.synchronize {yield}
    end
  end  # class Tracker

end  # module Logging::Stats

