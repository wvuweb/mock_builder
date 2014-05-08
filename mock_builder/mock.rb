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
require 'sanitize'

Dir["lib/*.rb"].each {|file| require file }
Dir["models/*.rb"].each {|file| require file }


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
    page = Page.new({:name => p.name})
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
    false
  end
  
  def is_mobile_version?
  end
  
  def admin_interface?
  end
  
  def mobile_ga
  end
  
  def h(arg=false)
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
  
  def params(options={})
    {:param => true, :param2 => false}
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
  
  def link_to_default_page(options={})
    link_to_page(default_page, options)
  end
  
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
    
    unless fname =~ /^_/
      fname = '_' + fname 
    end
    
    unless fname =~ /\.rhtml$/
      fname = fname + '.rhtml'
    end
    
    shared_theme = false
    if filename =~ /^shared\//
      # parts[0] = File.dirname(parts[0])
      shared_theme = true
    end
    
    parts[-1] = fname

    parts.unshift File.dirname(@filename) if parts.length == 1 || shared_theme

    if shared_theme
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
    nav_data = MockData.data_for('navigation')
    
    if nav_data && nav_data.kind_of?(Array)
      
      pages = []
      
      nav_data.each do |page|
        unless page.kind_of?(Array)
          pages << Page.new({:name => page})
        end
      end
      pages
    else
      Page.fake_children
    end
  end
  
  def current_page?(p)
    p.name == current_page
  end
  
  def current_page
    Page.current_page || site_menu[0]
  end

  def default_page
    site_menu.first
  end
  
  def default_page?
    current_page.name == default_page.name
  end

  def breadcrumbs
    return [] if default_page?
    crumbs = [current_page]
  end  
  
  def content_for(name=nil,permissions=nil)
    multiplier = name.to_s =~ /content/ ? 5 : 2
    MockData.data_for(name) || "Sample content for #{name.to_s}. " + LoremIpsum.generate(multiplier)
  end
  
  def content_tag(*args)
    <<-SNIPPET_ERROR
      <div class="error" style="background-color: red; padding: 5px; color: white;">Content Tags will not render in mock builder</div>
    SNIPPET_ERROR
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
  
  def link_to_blog_with_tag(arg=false, arg2=false)
    link_to(arg)
  end
  
  def link_to_article(article, blog)
    link_to(article.name)
  end
  
  #alias_method :link_to_article, :link_to_blog_with_tag
  
  def get_blog(*args)
  end
  
  def url_to_article(*args)
  end
  
  def form_remote_tag(*args)
  end
  
  def textile_editor(*args)
  end
  
  def textile_editor_initialize(*args)
  end
  
  def submit_tag(*args)
  end
  
  def end_form_tag(*args)
  end
  
  def resource_image(*args)
    image_tag("http://placekitten.com/300/200")
  end
  
  def resource_view?
    false
  end
  
  def blog_tags(*args)
    array = MockData.data_for('blog_tags') || Sanitize.clean(LoremIpsum.generate(1)).split(' ')
  end
  
  def javascript_include_tag(*args)
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
    yml = MockData.data_for 'blog_articles'
    
    if yml.kind_of?(Array)
      data = hashes2ostruct yml

      data.each do |article|
        
        article.article.body_html.to_s != "false" ? body = article.article.body_html : body = LoremIpsum.generate(article.article.paragraph_count)
        articles << BlogArticle.new(
          :body_html => body,
          :created_by => article.article.author,
          :published_on => Chronic.parse(article.article.published_on.to_s),
          :name => article.article.title
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
    basename = Pathname.new(@filename).basename
    foldername = File.basename(basename,".rhtml")
    blog_path = File.join(File.dirname(@filename), foldername)

    file_path = File.join(blog_path, '_' + filename.to_s + '.rhtml')
    
    unless File.exist?(file_path)
      file_path = 'shared/blog/' + filename.to_s + '.rhtml' 
    end
    
    file_path
  end
  
  def blog_engine_title(glue='')
  end
  
  def blog_article_date(fmt=nil)
    if fmt
      @@blog_article.published_on.eztime(fmt)
    else
      @@blog_article.published_on
    end
  end
  
  def blog_article_full_view?
    @blog_article = BlogArticle.new
    false
  end
  
  def blog_article_excerpt
    @@blog_article.body_html
  end
  
  def blog_article_content
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
    
    name = MockData.data_for(:site_name) || @params['name']
    url = @params['url'] || 'site_name'
    s = Space.new({:id => 1, :name => name, :url => url })

    # s = Space.current_space
    # s.id = 1
    # s.url  = @params['url'] || 'site_name'
    #s.name = MockData.data_for(:site_name) || @params['name']
    
    # binding.pry
    
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
    HTML
  end
end