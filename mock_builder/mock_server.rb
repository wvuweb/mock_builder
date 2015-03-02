require 'rubygems'
require "bundler/setup"

require 'pry'
require 'htmlentities'

require 'optparse'
require 'ostruct'

$LOAD_PATH << '.'

require 'webrick'
require 'mock.rb'


include WEBrick

class Class #:nodoc:
  def remove_subclasses
    Object.remove_subclasses_of(self)
  end

  def subclasses
    Object.subclasses_of(self).map { |o| o.to_s }
  end

  def remove_class(*klasses)
    klasses.flatten.each do |klass|
      # Skip this class if there is nothing bound to this name
      next unless defined?(klass.name)
      basename = klass.to_s.split("::").last
      parent = klass.parent
      # Skip this class if it does not match the current one bound to this name
      next unless parent.const_defined?(basename) && klass = parent.const_get(basename)
      parent.send :remove_const, basename unless parent == klass
    end
  end
end

class WEBrick::HTTPServlet::ERBHandler
  def do_GET(req, res)
    begin
      if Object.const_defined?('MockBuilder')
        klasses = %w{
          MockData
          LoremIpsum
          Page
          Space
          BlogArticle
          PagebuilderHelper
          BlogsHelper
          MockBuilder
        }
        Class.remove_class(*klasses)
        load 'mock.rb'
        puts 'Reloaded ' + klasses.length.to_s + ' classes'
      end

      res.body = MockBuilder.new({:filename => @script_filename, :request => req}).render
      res['content-type'] = 'text/html'
    rescue StandardError => ex
      raise
    rescue Exception => ex
      @logger.error(ex)
      raise HTTPStatus::InternalServerError, ex.message
    end
  end
end

options = OpenStruct.new
options.directory = (Pathname.new(Dir.pwd).parent.parent + "slate_themes").to_s
options.daemon = WEBrick::SimpleServer

OptionParser.new do |o|
  o.on('-d', '--directory directory', String, 'Directory to start hammer in') do |d|
    options.directory = d
  end

  o.on('-da', '--daemon daemon', Integer, 'If the server should run Daemonized') do |da|
    options.daemon = da == 1 ?  WEBrick::Daemon : WEBrick::SimpleServer
  end
  o.parse!(ARGV)
end

doc_root = options.directory

puts 'slate - mock server for theme testing'
puts '-' * 60
puts 'Starting in ' + doc_root + '...'
puts '-' * 60

s = HTTPServer.new(
  :Port            => 2000,
  :DocumentRoot    => doc_root,
  :ServerType      => options.daemon,
  :DirectoryIndex  => []
)

s.mount("/",       HTTPServlet::FileHandler, doc_root, true)
s.mount("/themes", HTTPServlet::FileHandler, doc_root, true)
s.mount("/SERVER", HTTPServlet::FileHandler, Dir::pwd, true)

trap("INT"){ s.shutdown }

s.start
