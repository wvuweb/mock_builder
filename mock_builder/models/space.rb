class Space
  attr_accessor :name, :url, :theme, :domain, :id, :default_page
  
  def initialize(options={})
    options.each { |k,v| instance_variable_set('@' + k.to_s, v) }
    @default_page = Page.new({:name => "Home"})
  end
  
  def self.current_space
    self.new({:name => get_name, :id => 1})
  end
  
  def self.find(arg=false, arg2=false)
    if arg === :all
      spaces = []
      5.times do
        spaces << self.new({:name => self.get_name, :id => 1})
      end
      spaces
    else
      self.new({:name => self.get_name, :id => 1})
    end
    
  end
  
  def domain
    "http://localhost:2000"
  end
  
  def self.get_name
    name = MockData.data_for(:site_name)
    
    if name == nil
      name = "Site Name"
    end
    
    name
  end
  
  def users
    User.new
  end
  
end