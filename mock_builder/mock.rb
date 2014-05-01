# $LOAD_PATH << '.'

require 'rubygems'
require "bundler/setup"

require 'pry'
require 'htmlentities'

require 'optparse'
require 'ostruct'
require 'erb'
require 'yaml'
require 'cgi'
require '../eztime/lib/eztime.rb'
require 'chronic'
require 'nokogiri'


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

class LoremIpsum
  def self.generate(paragraphs = 2)
  @@lipsum ||= <<-DUMMYTEXT.split("\n").map { |e| "<p>#{e.strip}</p>" }
    Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Etiam mollis, lectus vitae pharetra eleifend, augue risus suscipit felis, ac dapibus mi enim non sapien. Proin malesuada consequat orci. Nam tellus. Vestibulum fringilla justo quis justo. Fusce ac quam in lorem viverra sodales. Integer varius vestibulum magna. Pellentesque at ligula. Phasellus orci sapien, consectetuer in, tempus eu, condimentum vitae, nisl. Nulla tincidunt. Praesent dolor. Phasellus feugiat. Aenean est. Nullam varius.
    Curabitur odio risus, aliquet nec, elementum rhoncus, porta ac, mauris. In vitae odio vitae dui eleifend suscipit. Sed ac nisl. Pellentesque molestie elit id pede. Duis massa orci, congue vitae, porta ac, convallis vel, sem. Etiam quis dolor eu massa vestibulum accumsan. Integer leo. Nunc euismod tortor in quam. Sed elementum. Proin odio tortor, convallis molestie, ullamcorper in, tincidunt at, metus. Aliquam faucibus pulvinar turpis. Donec diam quam, rutrum quis, tristique ultrices, facilisis et, mauris. Pellentesque neque nibh, luctus vitae, ultrices nec, semper volutpat, erat. Maecenas pharetra leo ac leo. Sed luctus nonummy eros.
    Proin felis enim, feugiat ac, ultrices sit amet, consectetuer a, enim. Proin mollis nisl vitae metus. Fusce massa elit, ultrices vel, ornare et, cursus eu, lorem. Nulla sem nulla, ultrices non, venenatis id, vestibulum ac, augue. Phasellus tristique. Praesent feugiat luctus turpis. Nulla vitae leo nec nulla sodales tempor. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Curabitur ut orci. Nulla facilisi. Cras rhoncus erat vel felis. Donec dignissim ligula a dolor. Donec lectus.
    Nulla feugiat dignissim neque. Suspendisse et felis. Etiam mollis orci sit amet tortor. Vivamus nisl nunc, ornare sed, dictum vitae, bibendum fermentum, urna. Vestibulum accumsan, magna at interdum tempus, tellus mauris pellentesque dolor, eget mattis ligula sem laoreet libero. Aliquam vehicula, eros ut interdum varius, lectus ligula fringilla tortor, sit amet viverra felis nulla ut orci. Donec porta, neque in semper convallis, magna purus pharetra lorem, id porttitor orci metus vitae nunc. Mauris id leo. Aliquam tortor odio, faucibus eu, porta sollicitudin, lacinia ut, risus. Aliquam tincidunt nibh sit amet eros. Duis placerat felis vel odio. Nunc nisi massa, tempus porttitor, ornare vel, pellentesque blandit, enim. Aliquam a massa. Duis purus libero, cursus a, dapibus a, mollis ac, tellus. Suspendisse potenti. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Mauris eu libero ac lectus congue ornare. Duis posuere condimentum leo. Sed elit odio, pharetra vel, dictum a, hendrerit in, ante. Quisque vulputate, justo nec semper imperdiet, dolor nibh blandit erat, id facilisis nulla diam nec dui.
    Curabitur fringilla laoreet augue. Nulla nisi. Nullam dapibus ligula. Suspendisse potenti. Vestibulum sem. Donec fermentum, sem a mattis volutpat, quam elit congue nisi, eget tincidunt diam felis sed arcu. Sed at nulla ut tortor varius mattis. Donec rutrum. Morbi rhoncus, lectus eu venenatis feugiat, lorem lorem dictum purus, ac laoreet enim dui at nunc. Proin gravida enim eu odio. Pellentesque non velit. Curabitur et sem. Integer interdum dictum justo. Maecenas auctor lacinia arcu.
    Pellentesque arcu ligula, posuere non, accumsan et, scelerisque et, enim. Nullam sit amet dui. Sed nec nisi sed libero congue mattis. Morbi eget ipsum ut dolor elementum vehicula. Morbi mattis, elit id interdum tristique, dolor ipsum pharetra elit, in aliquet lorem est in magna. Nunc nisi metus, vestibulum vitae, lacinia non, semper a, velit. Nullam id lectus. Maecenas consectetuer. Nam vitae lacus eu libero tempor scelerisque. Aliquam convallis gravida turpis. Proin adipiscing nonummy elit.
    Quisque luctus. Nulla eros. Aenean lectus dui, consectetuer ut, semper ut, adipiscing cursus, velit. Donec imperdiet, urna id egestas lobortis, turpis lacus tristique justo, nec consectetuer purus augue in velit. Curabitur ante ligula, dapibus quis, ultrices et, dapibus nec, pede. Mauris eget massa non leo suscipit posuere. Duis sit amet augue. Suspendisse feugiat. In lacinia blandit velit. Integer arcu metus, commodo in, molestie sed, feugiat vitae, nibh. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. In venenatis turpis vel magna. Phasellus iaculis nibh. Nullam auctor sollicitudin felis. Mauris eu tellus. Curabitur tristique urna sed purus. Donec gravida laoreet lorem.
    Vestibulum adipiscing, est at lacinia ultrices, diam enim pulvinar sapien, sit amet facilisis leo orci a lorem. Mauris eget diam eget lectus condimentum consequat. In rhoncus nulla. Nulla tempus tellus ut lacus. Ut malesuada lobortis diam. Etiam ut tortor. Nam mollis, est quis elementum elementum, pede neque consequat mauris, aliquet congue dui nulla sit amet nibh. Vestibulum sed nulla. Nulla risus mauris, porta in, laoreet a, molestie vestibulum, mi. Praesent id sapien. Aenean viverra hendrerit ligula.
    Sed lacinia. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Sed ligula orci, interdum nec, pretium a, elementum vitae, elit. Nunc pharetra. Phasellus tincidunt. Donec orci. Vivamus porttitor accumsan tortor. Etiam ultrices, augue eu porttitor eleifend, ipsum orci malesuada neque, non mattis est sapien quis elit. Etiam sollicitudin porta tellus. Nulla in risus. Donec accumsan. Nulla tempor metus at neque. Sed faucibus fermentum lectus. Fusce tellus. Sed elit.
    Suspendisse non nibh. Aliquam ultricies ante vel lectus lacinia pretium. Proin id magna in lorem fringilla semper. Vestibulum in enim id massa volutpat gravida. Donec pharetra. Duis a quam. Proin ipsum. Etiam auctor, odio in euismod laoreet, tortor nibh aliquet ante, et dictum sapien nulla commodo nisi. Nullam imperdiet venenatis diam. Donec cursus diam ac ligula. Aliquam et sem.
  DUMMYTEXT
  
  (@@count ||= 0)
  @@count += 1
  srand 250 * @@count
  start = rand(@@lipsum.length - paragraphs)
  
  @@lipsum[start..start + paragraphs-1].join("\n  ")   
  end
end

class Page
  attr_accessor :direct_children, :siblings, :parent, :children
  attr_accessor :name, :path, :url, :full_url, :created_on, :id, :template, :hidden, :depth

  @@page_id = 1
  @url = nil
  @path = '/0/1/'

  def initialize(options={})
    options.each { |k,v| instance_variable_set('@' + k.to_s, v) }

    @direct_children = []
    @children = []
    @siblings = []
    @parent = []
  end
  
  def siblings(include_self, order=false)
    @siblings = []
  end
  
  def direct_children(arg=false)
    children
  end
  
  def children
    #@@singleton ||= self.new
    array = []
    array << @@singleton ||= self.new
    array << @@singleton ||= self.new
    array << @@singleton ||= self.new
    array << @@singleton ||= self.new
    array << @@singleton ||= self.new
  end
  
  def parent
    @@singleton ||= self.new
  end
  
  def depth
    0
  end
  
  def self.find(arg)
    @@singleton ||= self.new
  end
  
  def hidden?
    false
  end
  
  def last_modified; @created_on; end
  
  def self.create(name, options=nil)
    p = Page.new
    p.name = name
    p.id = @@page_id 
    p.created_on = Time.now
    #p.url =  #name.downcase.gsub(/[^0-9a-z_]/, '_').squeeze('_')
    p.path = '/0/1/'
    @@page_id += 1
    yield p if block_given?
    p
  end
  
  def full_url
    "http://localhost:2000"+ url
  end
  
  def url
    @url || name.downcase.gsub(/[^0-9a-z_]/, '_').squeeze('_')
  end
  
  def path_with_id; [path, id].join('/'); end
  
  def add_child(name, options=nil, &block)
    p = self.class.create(name, options, &block)
    p.full_url = File.join(url, p.url)
    p.path = File.join(path, p.id.to_s + '/')
    @direct_children << p
    p
  end

  def self.add_children(parent, branch)
    c = parent
    branch.each do |b|
      unless Array === b
        c = parent.add_child(b) 
      else
        add_children(c, b) 
      end  
    end  
  end
  
  def self.root
    p = Page.create('(root)')
    add_children p, MockData.data_for(:navigation) 
    p
  end  
  
  def self.current_page; @@singleton ||= self.create('Home'); end
end

class Space
  attr_accessor :name, :url, :theme, :domain, :id
  
  def initialize(options={})
    options.each { |k,v| instance_variable_set('@' + k.to_s, v) }
  end
  
  def self.current_space
    self.new
  end
  
  def self.find(arg)
    self.new
  end
  
  def domain
    "http://localhost:2000"
  end
  
end



class Blog

  def initialize(options={})
    options.each { |k,v| instance_variable_set('@' + k.to_s, v) }
  end
  
  def comments_enabled?
    false
  end
  
end

class BlogArticle
  attr_accessor :blog_id, :name, :url, :updated_on, :body_excerpt, :created_on, :created_by, :updated_on,
  :published_on, :body_exceprt_html, :body, :body_html, :published_on
  
  def initialize(options={})
    options.each { |k,v| instance_variable_set('@' + k.to_s, v) }
  end
  
  def has_excerpt?
    false
  end
  
end

module PagebuilderHelper
  
  def tidy(input)
    desired = Nokogiri::HTML::DocumentFragment.parse(input).to_xhtml(indent:3)
  end
  
  def show_code(code,html=false)
    
    if html
      code = tidy(code)
    end
    
    coder = HTMLEntities.new
    code = coder.encode(code)
      
    code
  end
  
  
  @@incrementer = 0
  def link_to(txt, options={}, attributes={})
    attrs = attributes.to_a.map { |k,v| "#{k}=\"#{v}\"" }.join(' ')
    "<a href=\"##{@@incrementer+=1}\" #{attrs}>#{txt}</a>"
  end
  
  def link_to_page(p, attributes = {})
    page = Page.create(p.name)
    if page.name == current_page.name
      (attributes[:class] ||= '') << ' current-page'
    elsif current_page.path_with_id[0, page.path_with_id.length] == page.path_with_id
      (attributes[:class] ||= '') << ' has-current-page'
    end 
    link_to(attributes[:text] || page.name, '#', attributes)   
  end  
  
  def editor_mode?
  end

  def mobile 
  end
  
  def is_mobile_version?
  end
  
  def mobile_ga
  end
  
  def google_analytics
    ga_data = MockData.data_for('google_analytics')
    if ga_data
      ga_data
    else
      <<-EOF
        <!-- NO GOOGLE ANALYTICS CODE IN MOCK DATA -->
      EOF
    end
  end
  
  def google_search_box(advanced = false, options = {})
    if advanced
      
      <<-EOF
      EOF
      
    else
      
      <<-EOF
        <form id="google_search" action="/s/" method="get" name="gs" role="search">
        		<label class="visuallyhidden focusable" for="q">Search</label>
            <input type="text" name="q" size="32" maxlength="256" placeholder="Search WVU..." />
            <input type="submit" name="btnG" value="Search" />
      
        		<div id="gs_links">
        	      
        		</div> <!-- /#gs_links -->
        </form>
      EOF
      
    end
  end
  
  def current_space
    Space.new({:name => site_name, :id => 1})
  end
  
  def share_this(site_name, space)
    st_data = MockData.data_for('share_this')
    if st_data
      st_data
    else
      "No Code Specified in mock data for ShareThis"
    end
  end
  
  def link_to_default_page(options={}); link_to_page(default_page, options); end
  
  def support_files
    '<link rel="stylesheet" type="text/css" href="/SERVER/mock.css" />'
  end

  def production?; true; end
  def space_name;  Space.current_space.name; end
  def site_name;   Space.current_space.name; end

  alias :site_title :site_name
  
  def page_name;  Page.current_page.name;  end
  def theme_path;  @path; end
  def shared_path; '../themes/shared'; end
  def resource_path; theme_path; end
  def images_path; File.join(theme_path, 'images/'); end
  
  def partial(filename,locals={})
    parts = filename.to_s.split('/')
    fname = parts.last
    fname = '_' + fname unless fname =~ /^_/
    fname = fname + '.rhtml' unless fname =~ /\.rhtml$/
    parts[-1] = fname
    
    parts.unshift File.dirname(@filename)
    if filename =~ /^shared\//
      parts[0] = File.dirname(parts[0]) 
    end
    
    if parts[1] == "shared"

      subparts = parts[0].split('/')
      slate_themes_pos = subparts.index('slate_themes')
      total_pos = subparts.length - 1 # subtract from total because first position is a "/"
      subtract_pos = total_pos-slate_themes_pos
      subparts = subparts.reverse.drop(subtract_pos).reverse
      subparts = subparts.join('/') 
      parts = parts.drop(1)
      shared_path = parts.join('/')
      full_path = subparts.concat('/'+shared_path)
      fname = full_path
      
    else
      fname = parts.join('/')
    end
    
    if File.exists?(fname)
      mb = MockBuilder.new(:filename => fname, :request => @request, :shared => true) #, :template => current_page.template)
      mb.render(locals)
    else
      <<-PARTIAL_ERROR
      <span class="partial_error">
          Failed to load partial <a title="#{fname}" href="#{@path + '/' + File.basename(fname)}">#{File.basename(fname)}</a>
      </span>
      PARTIAL_ERROR
    end
  end  
  
  def current_domain
    @request.host+":"+@request.port().to_s
  end
  
  def admin_toolbar
    
    files = []
    Dir.glob(File.dirname(@filename) + '/*.rhtml').collect do |f|
      
      text = File.basename(f)
      url = File.join(theme_path, text)
      
      if text =~ /^_/
        next
      else
        files << "<li><a href=\"#{url}\">#{text}</a></li>"
        
      end
    end
    
    files = files.join('')

    <<-TOOLBAR
    <div id="mock_toolbar">
      <a id="toggler" href="#" onclick="var t=document.getElementById('mock_tools');if(t.style.display=='none'){t.style.display='block';t.parentNode.style.width='180px';}else{t.style.display='none';t.parentNode.style.width='24px';}">(x)</a>
      <div id="mock_tools">
        <form action="#{@request.unparsed_uri}">
          URL of space: <input name="url" value="#{Space.current_space.url}" class="text" /><br />
          Space name: <input name="name" value="#{@params['name']}" class="text" /><br />
          <input type="submit" class="submit" value="Update" />
        </form> 
        <strong>Other templates:</strong>
        <ul>
          #{files}
        </ul>
      </div>
    </div> 
    TOOLBAR
  end
  
  alias :support_toolbar :admin_toolbar
  
  def site_menu
    Page.root.direct_children
  end
  
  def current_page?(p); p.name == current_page; end
  def current_page;     Page.current_page || site_menu[0]; end

  def default_page; site_menu.first; end
  def default_page?; current_page.name == default_page.name; end

  def breadcrumbs
    return [] if default_page?
    crumbs = [current_page]
  end  
  
  def content_for(name=nil,permissions=nil)
    multiplier = name.to_s =~ /content/ ? 5 : 2
    MockData.data_for(name) || "Sample content for #{name.to_s}. " + LoremIpsum.generate(multiplier)
  end  
  
  def last_modified; current_page.created_on; end
  
  def time_ago_in_words(date)
    now = Time.now
    posted = Chronic.parse(date)
    ((now - posted).to_i / (24 * 60 * 60)).to_s + " days"
  end
  
  def stylesheet(arg)
    path = if arg.to_s =~ /^shared\//
      '/' + arg
    else
      File.join(theme_path, arg)
    end  
    
    path += '.css' unless path =~ /\.css$/
    sprintf '<link href="%s" type="text/css" rel="stylesheet" />', path
  end
  
  def render_snippet(arg1, arg2, arg3)
    <<-SNIPPET_ERROR
      <div class="error" style="background-color: red; padding: 5px; color: white;">Template rendered snippets will not display in mock builder</div>
    SNIPPET_ERROR
  end
  
  def javascript_include_tag(arg, page=false)
    #printf '<script type="text/javascript" src="%s.js"'
  end

  def auto_discovery_link_tag(*args)
  end
  
  def image_tag(file)
    sprintf '<img src="%s" />', file
  end
end

module BlogsHelper
  
  def hashes2ostruct(object)
    return case object
    when Hash
      object = object.clone
      object.each do |key, value|
        object[key] = hashes2ostruct(value)
      end
      OpenStruct.new(object)
    when Array
      object = object.clone
      object.map! { |i| hashes2ostruct(i) }
    else
      object
    end
  end
  
  def blog_engine
    articles = []
    # articles << BlogArticle.new(
    #   :body_html => LoremIpsum.generate(2),
    #   :created_by => 'Chris',
    #   :published_on => Time.local(2007, 1, 12, 15, 42, 00),
    #   :name => 'Version 0.3.1 released'
    # )
    # 
    # articles << BlogArticle.new(
    #   :body_html => LoremIpsum.generate(1),
    #   :created_by => OpenStruct.new(:first_name => 'Dave'),
    #   :published_on => Time.local(2007, 2, 5, 11, 32, 00),
    #   :name => '15 sites & 26,000+ page views'
    # )
    
    yml = MockData.data_for 'blog_articles'
    
    if yml.kind_of?(Array)
      data = hashes2ostruct yml

      data.each do |article|
        
        article.body_html.to_s != "false" ? body = article.body_html : body = LoremIpsum.generate(article.paragraph_count)
        articles << BlogArticle.new(
          :body_html => body,
          :created_by => article.author,
          :published_on => Chronic.parse(article.published_on.to_s),
          :name => article.title
        )
      end
    elsif yml.kind_of?(String)
      yml.to_i.times do 
        articles << BlogArticle.new(
          :body_html => LoremIpsum.generate(3),
          :created_by => OpenStruct.new({:first_name => "Author", :last_name => "User"}),
          :published_on => Time.now,
          :name => "Article Title"
        )
      end
    else
      5.to_i.times do 
        articles << BlogArticle.new(
          :body_html => LoremIpsum.generate(3),
          :created_by => OpenStruct.new({:first_name => "Author", :last_name => "User"}),
          :published_on => Time.now,
          :name => "Article Title"
        )
      end
    end

    result = ''
    for @@blog_article in articles.reverse
      result += partial(blog_theme(:article),{:blog_article => @@blog_article, :blog => Blog.new})
    end
    result
  end
  
  def blog_theme(filename)
    file = File.join(File.dirname(@filename), '_' + filename.to_s + '.rhtml')
    file = 'shared/blog/' + filename.to_s + '.rhtml' unless File.exist?(file)
    file
  end
  
  def blog_engine_title(glue='')
  end
  
  def blog_article_date(fmt=nil)
    @@blog_article.published_on
  end
  
  def blog_article_full_view?
    false
  end
  
  def blog_article_excerpt
    @@blog_article.body_html
  end
  
  def blog_article_url
    '#'
  end
  
  def blog_article_comments_link
    '<a href="#">No comments</a>'
  end
  
  def reply_to_article_link
    '<a href="#">Reply to article</a>'
  end
  
  def blog_article_name
    @@blog_article.name
  end
  
  def blog_article_author
    @@blog_article.created_by
    #OpenStruct.new(:first_name => 'Chris')
  end
  
  def blog_rss_url(*args)
  end
  
  def blog_archives 
    hash = [Time.now.year-4, Time.now.year-3, Time.now.year-2, Time.now.year-1, Time.now.year].reverse
    # HtmlListMaker.new(hash).list
  end  
  
  def link_to_blog_archive(ba)
    link_to ba
  end
  
  def blog_recent_articles(*args) 
    ['Reminder: IE 7 Not Supported in slate',
     'Help Docs Have Been Updated',
     '15 sites & 26,000+ page views',
     'Version 0.3.1 released'
    ]
  end  
  
  def link_to_blog_article(ba)
    link_to ba
  end  
end

class MockBuilder
  include PagebuilderHelper
  include BlogsHelper
  
  @@data = nil
  
  def initialize(options)
    @exception = nil
    
    #@options = CommandOptions.prepare(options)
    @filename = options[:filename]
    @request  = options[:request]
    @path     = @request.path.dup
    @params   = @request.query
    
    s = Space.current_space
    s.id = 1
    s.url  = @params['url'] || 'site_name'
    #s.name = MockData.data_for(:site_name) || @params['name']

    if s.name.nil? || s.name.empty? 
      s.name = s.url.split('_').map { |e| e.capitalize }.join(' ')
    end
     
    basename = File.basename(@filename)
    #@path = File.join(*@path.split('/').reject { |e| e == basename })
    @path.gsub!(/\/([^\/]+.rhtml)/, '')
    
    @page = Page.current_page
    @page.template = File.basename(@request.path, File.extname(@request.path))
    #puts 'Template: %s (%s)'  % [options[:template], @request.path]
    
    f = @filename
    f = File.dirname(f) until File.directory?(f)
    
    if !options[:shared]
      @@data = MockData.load(f)
    end
    
  end
  
  def render(locals={})
    # puts '%s (%s)' % [current_page.template, @filename]
    # @page ||= Page.current_page
    #     puts @page.template
    #     unless (basename = File.basename(@filename, File.extname(@filename))) =~ /^_/
    #       @page.template = basename
    #     end  
    #     puts @page.template
    
    out = []
    
    if !@search_results
      search_results = MockData.data_for 'search_results'
      if search_results != nil
        @search_results = search_results
      else
        @search_results = <<-SEARCH_RESULTS
          <div class="mock_builder__error" style="background-color: red; padding: 5px; color: white;">Mock builder will not generate search results for you. Add results html to mock_data.yml with key: search_results</div>
        SEARCH_RESULTS
      end
    end
    
    locals.each { |k,v| instance_variable_set('@' + k.to_s, v) }

    raw = ''
    begin
      file = File.open(@filename)
      erb = ERB.new(raw = file.read, nil, '-')
      file.close
      out << erb.result(binding)
    rescue => exception
      @exception = exception
    end  
    
    if @exception
      generate_report(raw.split("\n"))
    else    
      out.join("\n")
    end
  end
  
  def generate_report(raw)
    r = @exception.backtrace.first.match(/(.*):([0-9]+):/)
    filename    = $1
    line_number = $2.to_i

    raw = File.readlines(filename) unless filename == '(erb)'
    
    around = 7
    startline = line_number - around
    startline = 0 if startline < 0
    endline = startline + 2 * around + 1
    
    index = startline
    code = raw[startline..endline].map do |line|
      index += 1
      number = '%03d' % index
      code = ::CGI.escapeHTML(line.gsub(/\t/, '  '))
      klass = index == line_number ? 'error' : ''
      code = "<tr><td class=\"n #{klass}\">#{number}:</td><td class=\"#{klass}\"><pre>#{code}</pre></td></tr>"
    end.join('') #filename == '(erb)' ? "\n" : '')
    
    <<-HTML
    <!-- <html>
    <head>
      <title>Exception Occurred!</title> -->
      <style type="text/css" media="screen">
        .exception h1,.exception h2,.exception h3,.exception h4,.exception h5,.exception h6 { font-family: Lucida Grande; font-weight: normal;  padding: 5px;}        
        .exception h1,.exception h2,.exception h3 { background: #900; color: #fff; padding: 15px;}
        .exception h2,.exception h3 { background: #222; padding: 5px 15px; font-size: 1.3em;}
        .exception h3 { font-size: 1.1em;}
        .exception td { color: black;}
        .exception td.error { color: red; }
        .exception .n { background: #999; color: white;}
        .exception td.n.error { vertical-align: top;}
        .exception pre { margin: 0; padding: 0; background: rgba(0, 0, 0, 0); border: 0;color: inherit; }
        .exception code { display: block; }
      </style>
      #{support_files}
    <!--</head>
    <body> 
    #{support_toolbar} -->
    <div class="exception">
     <h1>Error Rendering: #{@path}/#{File.basename(@filename)}</h1>  
     <h2>#{@exception.backtrace.first}</h2>
     <h3>#{@exception.message}
     </h3>
     <code>
       <table>#{code}</table>
     </code>  
     <blockquote style="display: none;">
       #{@exception.backtrace.join('')}
     </blockquote>
    </div>  
    <!-- </body>
    </html> -->
    HTML
  end
end

# if $0 == __FILE__
#   require 'pp'
#   def print_branch(branch, depth = 0)
#     branch.each do |b|
#       puts '->' * depth + b.name + ' (' + b.path + ')'
#       print_branch(b.direct_children, depth + 1)
#     end    
#   end 
#   
#   pp MockData.data_for(:navigation)
#   #pp Page.root
#   print_branch(Page.root.direct_children)
# end