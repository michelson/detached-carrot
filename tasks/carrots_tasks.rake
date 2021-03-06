require 'carrot'
#require 'detached-carrot'

require "#{RAILS_ROOT}/vendor/plugins/detached-carrot/lib/detached_carrot"

namespace :carrots do

  desc "Start processing jobs (process is daemonized)"
  task :start_processing_jobs => :environment do
    begin
      config = YAML.load_file("#{RAILS_ROOT}/config/carrots.yml")[RAILS_ENV]
      queue_pid_file = config['queue_pid_file']
      unless File.exist?(queue_pid_file)
        DetachedCarrot::Server.stats
        DetachedCarrot::Server.process(config['queue'])
        DetachedCarrot::Server.feedback("Started processing jobs")
      else
        DetachedCarrot::Server.feedback("Jobs are already being processed")
      end
    rescue Exception => error
      DetachedCarrot::Server.feedback(error.message)
    end
  end

  desc "Stop processing jobs"
  task :stop_processing_jobs do
    config = YAML.load_file("#{RAILS_ROOT}/config/carrots.yml")[RAILS_ENV]
    queue_pid_file = config['queue_pid_file']
    if File.exist?(queue_pid_file)
      system "kill -9 `cat #{queue_pid_file}`"
      DetachedCarrot::Server.feedback("Stopped processing jobs")
      File.delete(queue_pid_file)
    else
      DetachedCarrot::Server.feedback("Jobs are not being processed")
    end
  end

  desc "Server stats"
  task :stats do
    begin
      queue, items = DetachedCarrot::Server.stats
      DetachedCarrot::Server.feedback("Queue has #{items} jobs")
    rescue Exception => error
      DetachedCarrot::Server.feedback(error.message)
    end
  end

end
