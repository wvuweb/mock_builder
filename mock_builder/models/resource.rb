class Resource
  def initialize(options={})
    @name = "Resource"
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
      Resource.new({:name => "Resource", :id => 1})
    end
  end
  
  def find(arg=false, arg2=false)
    Resource.find(arg,arg2)
  end
  
  def each
    resources = []
    5.times do |i|
      resources << Resource.new({:name => "Resource "+i.to_s, :id => i})
    end
    resources
  end
end