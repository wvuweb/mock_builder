class BlogArticle
  attr_accessor :id, :blog_id, :name, :url, :updated_on, :body_excerpt, :created_on, :created_by, :updated_on,
  :published_on, :body_exceprt_html, :body, :body_html, :published_on, :summary
  
  def initialize(options={})
    @id = 1
    @name = "Mock Article"
    @summary = "Everyone loves kittens!"
    @body_excerpt = LoremIpsum.generate(1)
    options.each { |k,v| instance_variable_set('@' + k.to_s, v) }
  end
  
  def has_excerpt?
    false
  end
  
  def self.find(arg=false, arg2=false)
    self.new()
  end
  
  def find(arg=false, arg2=false)
    BlogArticle.new()
  end
  
  def self.count(arg=false, arg2=false)
    6
  end
  
  def self.find_by_sql(arg=false)
    self.new()
  end
  
  def has_video?
    false
  end
  
  def resources
    Resource.new()
  end
  
  def meta_datas
    MetaData.find(:all)
  end
  
end