class ListMaker
  def initialize(hash)
    @hash = hash
    @indent = "  "
    @level = 0
    @out = []
  end

  def append(tag,value=nil)
    str = @indent * @level + "#{tag}"
    str += @tag_space + value.to_s unless value.nil?
    str += "\n"
    @out << str
  end

  def ul(hash)
    open_tag('ul') { li(hash) }
  end

  def li(hash)
    @level += 1
    hash.each do |key,value|
      open_tag('li',key) { ul(value) if value.is_a?(Hash) }
    end
    @level -= 1
  end

  def list
    ul(@hash)
    @out.join
  end
end

class HtmlListMaker < ListMaker
  def initialize(hash)
    super
    @tag_space = ""
  end

  def open_tag(tag,value=nil,&block)
    append("<#{tag}>",value)
    yield if block_given?
    append("</#{tag}>")
  end
end

class HamlListMaker < ListMaker
  def initialize(hash)
    super
    @tag_space = " "
  end

  def open_tag(tag,value=nil,&block)
    append("%#{tag}",value)
    yield if block_given?
  end

end