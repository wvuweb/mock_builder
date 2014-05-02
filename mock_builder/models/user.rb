class User
  
  attr_accessor :name, :display_name, :role_name, :username
  
  def initialize(options={})
    @name = "User"
    @display_name = "Display Name"
    @username = "username"
    @role_name = "role"
    options.each { |k,v| instance_variable_set('@' + k.to_s, v) }
  end
  
  def self.find(arg=false, arg2=false)
    if arg === :all
      users = []
      5.times do |i|
        users << User.new({:name => "User "+i.to_s, :id => i})
      end
      users
    else
      User.new({:name => "User", :id => 1})
    end
  end
  
  def find(arg=false, arg2=false)
    User.find(arg,arg2)
  end
end