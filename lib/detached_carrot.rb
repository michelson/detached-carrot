begin
  CARROT_CONFIG = YAML.load_file("#{File.dirname(__FILE__)}/../../../../config/carrots.yml")[RAILS_ENV] unless defined?(CARROT_CONFIG)
  CARROT_LOG = Logger.new(CARROT_CONFIG['log_file'])
  #Carrot.stop 
  CARROT = Carrot.queue(CARROT_CONFIG['queue'])
  
   
end



module DetachedCarrot

  class Server
    #include Carrot
    
  #  def self.autoload_missing_constants
  #    yield
  #  rescue ArgumentError, MemCache::MemCacheError => error
  #    lazy_load ||= Hash.new { |hash, key| hash[key] = true; false }
  #    retry if error.to_s.include?('undefined class') && 
   #     !lazy_load[error.to_s.split.last.constantize]
  #    raise error
  #  end

    def self.running_pops?
      config = YAML.load_file("#{RAILS_ROOT}/config/carrots.yml")[RAILS_ENV]
      if File.exist?(config['queue_pid_file'])
        Process.getpgid(File.read(config['queue_pid_file']).to_i) rescue return false
      else
        return false
      end
    end

    def self.prepare(queue)
      self.feedback("Queue processor started for `#{queue}`.")
      start_processing(queue)
    end
    
    def self.process(queue, daemonize = true)
      pid = fork do
        Signal.trap('HUP', 'IGNORE') # Don't die upon logout
        #loop { CARROT.pop(queue) }
        #while msg = CARROT.pop(:ack => true)
      puts "Eating carrots ...."
        loop{ 
          pop
          sleep(2)
          }
      end
      if daemonize
        File.open(CARROT_CONFIG['queue_pid_file'], "w") do |pid_file|
          pid_file.puts pid
        end
        Process.detach(pid)
      end
    end

   def self.pop
     return unless CARROT.message_count > 0

      begin
      #  job = autoload_missing_constants { CARROT.get(queue) }
      job = CARROT.pop(:ack => true)
      puts "Popping: #{job.inspect}"
      job = JSON.parse(job)
      CARROT.ack
      options = []
      options << job['options'][0].key_strings_to_symbols! unless job['options'][0].nil?
      puts " the options are #{options.inspect}"
        args = [job['task']] + options # what to send to the object
        puts "passing arguments #{args.inspect}"
        if job['id']
          job['type'].constantize.find(job['id']).send(*args)
        else
          job['type'].constantize.send(*args)
        end
        CARROT_LOG.info "[#{Time.now.to_s(:db)}] Popped #{job['task']} on #{job['type']} #{job['id']}"
      rescue ActiveRecord::RecordNotFound
        CARROT_LOG.warn "[#{Time.now.to_s(:db)}] WARNING #{job['type']}##{job['id']} gone from database."
      rescue ActiveRecord::StatementInvalid
        CARROT_LOG.warn "[#{Time.now.to_s(:db)}] WARNING Database connection gone, reconnecting & retrying."
        CARROT.publish(job.to_json)
        ActiveRecord::Base.connection.reconnect!
        retry
      rescue Exception => error
        CARROT_LOG.error "[#{Time.now.to_s(:db)}] ERROR #{error.message}"
        puts "[#{Time.now.to_s(:db)}] ERROR #{error.message}"
        
      end
    end

    def self.stats
      return CARROT_CONFIG['queue'], CARROT.sizeof(CARROT_CONFIG['queue'])
    end

    def self.feedback(message)
      puts "=> [SIMPLIFIED CARROT] #{message}"
    end

    def self.stats
      puts "Queued #{CARROT.message_count} messages"
      puts
      #return CARROT_CONFIG['queue'], CARROT.sizeof(CARROT_CONFIG['queue'])
    end
    
    
    def self.message_count
     return CARROT.message_count
    end

    def self.feedback(message)
      puts "=> [CARROTS CARROT] #{message}"
    end

  end

end


class Hash
  # Recursively replace key names that should be symbols with symbols.
  def key_strings_to_symbols!
    r = Hash.new
    self.each_pair do |k,v|
      if (k.kind_of? String)
        r[k.to_sym] = v
      else
        r[k] = v
      end
    end
    return r
  end
end

