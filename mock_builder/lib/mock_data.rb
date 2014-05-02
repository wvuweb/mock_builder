class MockData
  @@data = nil
  def self.load(theme_name='')
    basename = 'mock_data.yml'
    yml = File.join(theme_name, basename)
    yml = basename unless File.exists?(yml)
    
    file = File.open(yml)
    erb = ERB.new(file.read, nil, '-')
    file.close
    yml_data = erb.result(binding)
    @@data = YAML::load(yml_data)
  end
  
  def self.data_for(key)
    load if @@data.nil?
    unless @@data == false
      data = @@data[key.to_s]
      if data == :style_guide
        data = File.read('style_guide.html')
      end
    else
      data = false
    end
    data
  end
end