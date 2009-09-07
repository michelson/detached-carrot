# DetachedCarrot

A port of SimplifiedStarling plugin for push&amp;pop active_record tasks to RabbitMQ
SimplifiedStarling is a very cool plugin that works on StarlingMQ, since Starling presented some problems with the latest versions of memcached-client i decided to work on porting SimplifiedStarling to work on RabbitMQ.

this plugin works with carrots gem a great gem for to manage the queues of RabbitMQ. so what makes DetachedCarrot is simply detach the process and push AR tasks in the same way SimplifiedStarling does.
so probably the switch to ss to dc should be transparent.

# Getting Started

## install

	sudo gem install famoseagle-carrot
	script/plugin install git@github.com:michelson/detached-carrot.git

# Diving In

	[simplifiedStarling] (http://github.com/fesplugas/simplified_starling/tree/master) 
	[carrot] (http://github.com/famoseagle/carrot/tree/master)
	[a nice-quick guide about installing erlang, rabbit and nanites] (http://github.com/ezmobius/nanite/tree/master)


# Dependencies & requisites

  Erlang: the language
  Rabbit: the Erlang Message Queue
  Carrot: A gem for synchronous amqp client

## Example
    # start rabbit
    $   sudo rabbitmq-server 

   
# Acknowledgments

 Amos Elliston,  author of carrot gem, a nice synchronous amqp client
 Francesc Esplugas Marti, for his cool SimplifiedStarling plugin 
 Blaine Cook, Twitter Inc. for this nice queue system.
 Joe Van Dyk for his work on adding options to tasks, Tanga.com LLC


# License

Copyright (c) 2009 [Miguel Michelson Martinez], released under the MIT license

