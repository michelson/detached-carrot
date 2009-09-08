RAILS_ENV = 'test'
require 'rubygems'

require 'active_record'
require 'mocha'
require 'ruby-debug'
#require 'detached_carrot'
#require 'detached_carrot/active_record'

# Mocking stuff
CARROT_CONFIG = {}
CARROT_CONFIG['queue'] = 'test'

require 'test/unit'
# Add your module file here
require 'carrot'
require File.dirname(__FILE__) + '/../lib/detached_carrot/active_record'
require File.dirname(__FILE__) + '/../lib/detached_carrot'


class Logger
  def initialize(file); end
  def warn(s); end
  def info(s); end
  def error(s); end    
end

class Server
# CARROT = Carrot.queue('name')
end

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")

def setup_db
  ActiveRecord::Schema.define(:version => 1) do
    create_table :posts do |t|
      t.string :name, :nil => false
      t.boolean :status, :default => false
    end
  end
end

def teardown_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.drop_table(table)
  end
end

class Post < ActiveRecord::Base

  def rebuild
    self.update_attributes :status => true
  end

  def self.publish_all
    update_all :status => true
  end

  def self.unpublish_all
    update_all :status => false
  end

  def self.generate(options = {})
    create :name => options[:name], :status => false
  end

  def update_name(options = {})
    update_attribute :name, options[:name]
  end

end


class DetachedCarrotTest < Test::Unit::TestCase

  def setup
    setup_db
    Post.create(:name => "First Post")
  end

  def teardown
    teardown_db
  end

  def test_array_class_is_not_affected_by_method_overwrite
    a = [ "a", "b", "c" ]
    a.push("d", "e", "f")
    assert_equal a, ["a", "b", "c", "d", "e", "f"]
  end
  
  def test_should_push_a_class_method_on_post
    post = Post.find(:first)
    assert !post.status
    Post.push('publish_all')
    DetachedCarrot::Server.pop
    post = Post.find(:first)
    assert post.status
    Post.push('unpublish_all')
    post = Post.find(:first)
    assert post.status
    DetachedCarrot::Server.pop
    post = Post.find(:first)
    assert !post.status
  end
  
  def test_should_push_an_instance_method_on_post
    post = Post.find(:first)
    assert !post.status
    Post.find(:first).push('rebuild')
    DetachedCarrot::Server.pop
    post = Post.find(:first)
    assert post.status
  end
  
  def test_should_insert_10_items_and_count
    Post.destroy_all
    assert_equal Post.count, 0
    10.times { Post.push('generate') }
    assert_equal 10, DetachedCarrot::Server.message_count
    10.times { DetachedCarrot::Server.pop }
    sleep 3
    assert_equal 0, DetachedCarrot::Server.message_count
    assert_equal 10, Post.count
  end
  
  def test_class_methods_support_options
   Post.push(:generate, { :name => "Joe" })
    DetachedCarrot::Server.pop
    assert Post.find_by_name("Joe")
  end
  
  def test_instance_methods_support_options
    post = Post.find(:first)
    assert post.name != "Joe"
    post.push(:update_name, { :name => "Joe" })
    DetachedCarrot::Server.pop
    assert post.reload.name == "Joe"
  end

  def test_when_raises_active_record_statement_invalid_exception_job_does_not_get_lost    
    post = Post.find(:first)
    assert post.reload.name != "Joe"
    post.push(:update_name, { :name => "Joe" })
    # First try to find raises StatementInvalid, so the rescue is executed
    # On the second try, find works as usual
    Post.stubs(:find).raises(ActiveRecord::StatementInvalid).then.returns(post)
    DetachedCarrot::Server.pop
    assert post.reload.name == "Joe"
  end
end