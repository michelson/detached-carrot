# DetachedCarrot

A port of SimplifiedStarling plugin for push&amp;pop active_record tasks to RabbitMQ.

SimplifiedStarling is a very cool plugin that works on StarlingMQ, since Starling presented some problems with the latest versions of memcached-client i decided to work on porting SimplifiedStarling to work on RabbitMQ.

This plugin works with carrots gem a great gem for to manage the queues of RabbitMQ. so what makes DetachedCarrot is simply detach the process and push AR tasks in the same way SimplifiedStarling does.
so probably the switch to ss to dc should be transparent.


# Dependencies & requisites

  Erlang: The lang

  RabbitMQ: A Erlang Message Queue

  Carrot: synchronous amqp client gem

# Getting Started

## Install

	sudo gem install famoseagle-carrot

Install this Rails plugin as usual.
	script/plugin install git@github.com:michelson/detached-carrot.git
	
## Start RabbitMQ

	$  sudo rabbitmq-server
	
## Tasks

	rake carrots:start_processing_jobs
	rake carrots:stop_processing_jobs
	
## Stats

		rake carrots:stats

## Usage

Example 1, Push a +newsletter+ job into +rabbitMQ+.
	Newsletter.find(params[:id]).push('deliver')
 
Example 2, Confirm an +order+ payment and push into +rabbitMQ+ an stock recalculation job.
	Stock.push('recalculate')
 
Example 3 , Push a task with options.
	Repository.push :generate, { :token => token }
	
## log

Each time a job is pushed and popped to the queue is logged.

	[2008-06-30 11:06:03] Pushed dispatch order
	[2008-06-30 11:06:03] Popped dispatch order

If database connection goes down or dies after a few hours of inactivity 
database connection will be restored and job will be processed.

	[2008-06-30 11:06:42] Pushed rebuild Page 3
	[2008-06-30 11:06:42] WARNING Database connection gone, reconnecting & retrying.
	                      {:type=>"Order", :task=>"dispatch", :id=>nil}
	[2008-06-30 11:06:44] Popped rebuild Page 3

If the record you're trying to process is removed from the database before 
the queue is processed you'll see a warning on the logs.

	[2008-06-30 11:06:50] Pushed rebuild Page 3
	[2008-06-30 11:06:50] WARNING Page#3 gone from database.

# Diving In

[simplifiedStarling] (http://github.com/fesplugas/simplified_starling/tree/master) 

[carrot] (http://github.com/famoseagle/carrot/tree/master)

[a nice-quick guide about installing erlang, rabbit and nanites] (http://github.com/ezmobius/nanite/tree/master)

# Acknowledgments

	Amos Elliston,  author of carrot gem, a nice synchronous amqp client
	Francesc Esplugas Marti, for his cool SimplifiedStarling plugin 
	Joe Van Dyk for his work on adding options to tasks, Tanga.com LLC

# License

Copyright (c) 2009 [Miguel Michelson Martinez], released under the MIT license