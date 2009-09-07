module DetachedCarrot

  ##
  # Push record task into the queue
  #
  def push(task, *args)

    ActiveRecord::Base.verify_active_connections! if defined?(ActiveRecord)

    job = {}
    job[:type] = (self.kind_of? Class) ? self.to_s : self.class.to_s
    job[:id] = (self.kind_of? Class) ? nil : self.id
    job[:task] = task
    job[:options] = args

    CARROT.publish(job.to_json)
    puts "pushed #{job.to_json}"
    CARROT_LOG.info "[#{Time.now.to_s(:db)}] Pushed #{job[:task]} on #{job[:type]} #{job[:id]}"
    puts "[#{Time.now.to_s(:db)}] Pushed #{job[:task]} on #{job[:type]} #{job[:id]}"
    
  rescue Exception => error
    CARROT_LOG.error "[#{Time.now.to_s(:db)}] ERROR #{error.message}"
  end
  

end

module DetachedCarrot

  class ActiveRecord::Base
    include DetachedCarrot
  end

end

class Class
  include DetachedCarrot
end

ActiveRecord::Base.send(:include, DetachedCarrot)