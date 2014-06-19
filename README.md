# Mock Builder v2.0

Mock Builder v2.0 is a theme development tool for the [Slate](http://slatecms.wvu.edu/ "Slate") CMS template rendering engine.  Mock Builder was created to help you iterate quickly on themes and template markup.  

Mock Builder v2.0 is **NOT** for content creation.  

Mock Builder v2.0 fixes many problems that were issues in the first version of mock builder.  The new version also builds on the little known feature such as mock_data.yml.


###Dependencies

* Ruby 1.9.3-p484


###Mac OSX Installation

1. Install RVM: [Ruby Version Manager](http://rvm.io/ "Ruby Version Manager")

    `\curl -sSL https://get.rvm.io | bash -s stable`
    
    then run
    
    `rvm requirements`

2. Checkout repo into your ~/Sites/ directory:
    
    * `git clone https://github.com/wvuweb/mock_builder.git`
    * *** If you have the old version of mock builder installed delete the directory first. *** 


3. Change directory to mock builder install 

    `cd ~/Sites/mock_builder/`

4. If RVM prompts you to run the following: 

    `rvm install 1.9.3-p484@mock_builder`

5. Then run 

    `bundle install`

5. Create a alias in your profile (.bash_profile or .profile)

    * `alias mock='rvm use ruby-1.9.3-p484@mock_builder && cd ~/Sites/mock_builder/mock_builder && ruby mock_server.rb ~/Sites/slate_themes'`
    * *** If you have the old version of mock builder installed remove the old alias first. *** 
    

### Windows Installation 
***Coming Soon***
    
##mock_data.yml 

Mock Data is a feature that allows you to fill <%= content_for(:main) %> tags with actual content rather then having mock builder fill it with LoremIpsum paragraphs.

To use this feature, create a file with the name: mock_data.yml in the root of your theme.

###Example 1:

**mock_data.yml:**

    main: This is a test String
    aside:  This is a test String that will show up in the aside.

**example.rhtml:**

    <div class="main">
        <%= content_for(:main) -%>
    </div>
    <div class="aside">
        <%= content_for(:aside) -%>
    </div>

**example.rhtml output:**

    <div class="main">
        This is a a test String
    </div>
    <div class="aside">
        This is a test String that will show up in the aside.
    </div>
    
###Example 2:

**mock_data.yml:**

    main: |
        <div>I've <strong>got</strong> some html</div>
        <p>Notice the pipe (|) trailing main, it tells YAML that HTML is going to follow.</p>
    aside:  |
        <div>I also have some html, you could do some lists:</div>
        <ul>
            <li>Item 1</li>
            <li>Item 2</li>
            <li>Item 3</li>
        </ul>
        <p>Or any other html that you might need</p>

**example.rhtml:**

    <div class="main">
        <%= content_for(:main) -%>
    </div>
    <div class="aside">
        <%= content_for(:aside) -%>
    </div>

**example.rhtml output:**

    <div class="main">
        <div>I've <strong>got</strong> some html</div>
        <p>Notice the pipe trailing main, it tells YAML that HTML is going to follow.</p>
    </div>
    <div class="aside">
        <div>I also have some html, you could do some lists:</div>
        <ul>
            <li>Item 1</li>
            <li>Item 2</li>
            <li>Item 3</li>
        </ul>
        <p>Or any other html that you might need</p>
    </div>
    
###Advance Example (blogs):

**mock_data.yml

    blog_articles:
    - article:
        title: This is the articles title
        author:
            first_name: Frank
            last_name: Sinatra
        paragraph_count: 2
        body_html: false
        created_on: 40000 days ago
        published_on: 2014-02-24 at noon
    - article:
        title: This is the articles title 2
        author:
            first_name: Bob
            last_name: Jones
        paragraph_count: 1
        body_html: false
        created_on: 3 days ago
        published_on: 2 days ago
    - article:
        title: This is the articles title 3
        author:
            first_name: Howard
            last_name: TheDuck
        paragraph_count: 3
        body_html: |
            <h3>This is some custom blog article html.</h1>
            <p>It's <em>only</em> here for <strong>fun</strong>, okay?</p>
        created_on: 4 days ago
        published_on: 3 days ago


**Example explaination:**

In the above example there are many things going on that you may find useful.

*blog_articles* key fills in for <%= blog_engine %> tag.

No longer will you get an error message associated with a blog_engine tag in mock_builder.  Instead now you can fill the view with actual content, or auto generated content.

*- article* key is requried to use the blog_article key.  Each article contains the basic items needed to generate a blog_article in mock builder.

*author* key is a compound key, it requires two sub keys (first_name, last_name).

*paragraph_count* key controls how many auto generated paragraphs you want for the article, however it depends on the following key to tell mock builder if it is being used.

*body_html* key can have 2 switch states.  If the switch is marked false, then the body html for the article will use LoremIpsum prefill and the paragraph count.  If the switch state is a pipe character (|) then it will expect provided custom html to follow.

*created_on* key is for the date in which the article was created.  This field can take human language and translate it to a date object.  If you type *2 days ago* mock builder is smart enough to create a date based on todays date.  You could also type *02/12/2014 at noon* an it will correctly create a date.

*published_on* key is the same as created_on, however for the published_on field.  Currently mock builder is not smart enough to order the articles by their published_on date.