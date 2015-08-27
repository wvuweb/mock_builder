require 'rubygems'
require "bundler/setup"

require 'pry'
require 'htmlentities'

require 'optparse'
require 'ostruct'

require 'colorize'
require 'git'

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
    if da == 1
      puts "INFO: ".colorize(:blue)+"Mock Server starting in Daemon mode".colorize(:light_cyan)
    else
      puts "INFO: ".colorize(:blue)+"Mock Server starting in Simple Server mode".colorize(:light_cyan)
    end
  end
  o.parse!(ARGV)
end


g = Git.open("../")
ref = g.log.first {|l| l.sha }
remote = g.lib.send(:command, 'ls-remote').split(/\n/)[1].split(/\t/)[0]

if ref.to_s != remote.to_s
  puts " "
  puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!".colorize(:red)
  puts "!!!".colorize(:red)+" WARNING YOU ARE BEHIND ON MOCK BUILDER VERSIONS".colorize(:light_cyan)+" !!!".colorize(:red)
  puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!".colorize(:red)
  puts " "
  puts "Repository is currently at ref: ".colorize(:light_white)+(ref.to_s+" ").colorize(:light_magenta)
  puts "Remote is currently at ref: ".colorize(:light_white)+(remote.to_s+" ").colorize(:light_magenta)
  # puts "Learn how to update Hammer at: ".colorize(:light_white)+update_url.colorize(:light_cyan)
  puts " "
  puts " "
  puts "Update Mock Builder by using using the following command: ".colorize(:light_white)
  puts " "
  puts "vagrant mock-builder update".colorize(:light_green)
  puts " "
  puts "Mock Builder will automatically restart after updating itself".colorize(:light_white)
  puts " "
  puts " "
end


doc_root = options.directory

puts "Mock Builder Server - for slate theme testing is loading...".colorize(:light_green)
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
