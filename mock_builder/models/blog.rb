class Blog
  
  attr_accessor :id, :name

  def initialize(options={})
    @id = 1
    @name = "Blog"
    options.each { |k,v| instance_variable_set('@' + k.to_s, v) }
  end
  
  def comments_enabled?
    false
  end
  
  def self.find(arg=false, arg2=false)
    self.new()
  end
  
  def categories
    Category.new()
  end
  
  def meta_datas
    MetaData.new()
  end
  
  def articles
    BlogArticle.new()
  end
  
end