# WVUToday only
class MetaData
  
  attr_accessor :name, :id
  
  def initialize(options={})
    @id = 1
    @name = "Resource"
    options.each { |k,v| instance_variable_set('@' + k.to_s, v) }
  end
  
  def self.find(arg=false, arg2=false)
    if arg === :all
      metas = []
      5.times do |i|
        metas << MetaData.new({:name => "Meta Data "+i.to_s, :id => i})
      end
      metas
    else
       MetaData.new()
    end
  end
  
  def find(arg=false, arg2=false)
    MetaData.find(arg, arg2)
  end
  
  def articles
    BlogArticle.new()
  end
  
  def each
    MetaData.find(:all)
  end
  
end

class Category
  
  attr_accessor :name, :id
  
  def initialize(options={})
    @id = 1
    @name = "Category"
    options.each { |k,v| instance_variable_set('@' + k.to_s, v) }
  end
  
  def self.find(arg=false, arg2=false)
    if arg === :all
      categories = []
      5.times do |i|
         categories << Category.new({:name => "Category "+i.to_s, :id => i})
      end
      categories
    else
      self.new()
    end
  end
  
  def find(arg=false, arg2=false)
    Category.find(arg, arg2)
  end
  
end

class Resource
  
  attr_accessor :name, :id, :height
  
  def initialize(options={})
    @id = 1
    @name = "Resource"
    @height = 300
    options.each { |k,v| instance_variable_set('@' + k.to_s, v) }
  end
  
  def self.find(arg=false, arg2=false)
    if arg === :all
      resources = []
      5.times do |i|
         resources << Resource.new({:name => "Resource "+i.to_s, :id => i})
      end
      resources
    else
      self.new()
    end
  end
  
  def find(arg=false, arg2=false)
    Resource.find(arg, arg2)
  end
  
  
end