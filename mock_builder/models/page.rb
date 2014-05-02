class Page
  
  attr_accessor :name, :path, :url, :full_url, :created_on, :last_modified, :id, :template, :hidden, :depth
  attr_accessor :direct_children, :siblings, :parent, :children
  
  def initialize(options={})
    @id = 1
    @page_id = 1
    @depth = 1
    @name = "Home"
    @path = "/0/1/"
    @created_on = Time.now
    @last_modified = Time.new
    @hidden = false
    @url = "home"
    options.each { |k,v| instance_variable_set('@' + k.to_s, v) }
    @direct_children = []
    @children = []
    @siblings = []
    @parent = []
  end
  
  def self.create(options={})
    self.new(options)
  end
  
  def self.current_page
    self.new()
  end
  
  def self.root
    self.new(:name => "(root)", :depth => 0, :path => "0", :url => "(root)")
  end
  
  def url
    @url || name.downcase.gsub(/[^0-9a-z_]/, '_').squeeze('_')
  end
  
  def hidden?
    false
  end
  
  def path_with_id
    [path, id].join('/')
  end
  
  def self.fake_children
    children = []
    5.times do |i|
      i = i+1
      children << self.new(:id => i+1, :name => "Page "+i.to_s, :depth => 1 )
    end
    children
  end
  
  def parent
    if @parent == []
      Page.root
    end
  end
  
  def siblings(*args)
    if @siblings == []
      @siblings
    end
  end
  
  def direct_children(*args)
    if @direct_children == []
      Page.fake_children
    end
  end
end