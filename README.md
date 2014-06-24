# Mock Builder v2.0

Mock Builder is a local theme development tool for the [Slate](http://slatecms.wvu.edu/ "Slate") CMS template rendering engine.  Mock Builder was created to help you iterate quickly on themes and template markup.

Mock Builder is **NOT** for content creation.

Mock Builder fixes many problems that were issues in the first version of mock builder.  The new version also builds on the little known feature such as `mock_data.yml`.


###Dependencies

* Ruby 1.9.3-p484


###Mac OSX Installation

1. If you don't already have one, go to `~/Sites/` and make a folder called `slate_themes`. You can do this via OSX Finder or via the following command in Terminal:
    *  `cd ~/Sites/ && mkdir slate_themes`
        * To use Mock Builder v2, **all the themes you want to test locally must reside in the `slate_themes` folder**.
        * If you have miscellaneous themes in your `~/Sites/` directory, it would be best to re-`svn checkout` those themes into the `slate_themes` folder.

1. Install [Bundler](http://bundler.io/) if you don't already have it:

    * `gem install bundler`
        * If you get a "Permission denied" error of some sort, run `sudo gem install bundler`

1. Install RVM: [Ruby Version Manager](http://rvm.io/ "Ruby Version Manager")

    `\curl -sSL https://get.rvm.io | bash -s stable`
    
    then run
    
    `rvm requirements`
    
    * Occasionally, RVM will ask you to run a few other commands (like `source` or the like). When installing, if it asks you to run other commands, please do so!
    * Installing RVM could take a while (30 minutes to 1.5 hours depending). Please be patient.

1. Clone the Mock Builder repo into your `~/Sites/` directory:
    
    * `git clone https://github.com/wvuweb/mock_builder.git`
        * ***If you have the old version of mock builder installed delete the old directory first.***
        * If you get `-bash: git: command not found` when you run `git clone`, go [install Git](http://git-scm.com/), then re-run the above command after quitting and reopening terminal.


1. Change directory to the mock builder install 

    `cd ~/Sites/mock_builder/`

1. If RVM prompts you, run the following: 

    `rvm install 1.9.3-p484@mock_builder`

1. Then run 

    `bundle install`

1. Create an alias in your profile:
    
    * Run `cd ~ && open .bash_profile` or `cd ~ && open .profile` via the Terminal (depending on which one you use). 
        * If you don't know which file you use, paste the alias below into both files.
    * Paste `alias mock='rvm use ruby-1.9.3-p484@mock_builder && cd ~/Sites/mock_builder/mock_builder && ruby mock_server.rb ~/Sites/slate_themes'` into your profile.
    * ***If you have the old version of mock builder installed remove the old alias first.***

1. Completely quit Terminal. Then reopen it and type `mock`

1. Visit `http://localhost:2000` in your browser. Navigate to a theme to test it locally.

1. Congrats, you're up and running! You'll probably want a `mock_data.yml` file. Keep reading to see how to get that set up.
    

### Windows Installation 
***Coming Soon***
    
## mock_data.yml 

Mock Data is a feature that allows you to fill `<%= content_for(:main) %>` tags with actual content rather than having Mock Builder fill it with Lorem Ipsum paragraphs.

To use this feature, create a file with the name: `mock_data.yml` in the root of your theme.

### Example 1:

**mock_data.yml:**

```yaml
    main: This is a test String
    sidebar:  This is a test String that will show up in the sidebar.
```

**example.rhtml:**

```html
    <div class="main">
        <%= content_for(:main) -%>
    </div>
    <div class="sidebar">
        <%= content_for(:sidebar) -%>
    </div>
```

**example.rhtml output:**

```html
    <div class="main">
        This is a a test String
    </div>
    <div class="sidebar">
        This is a test String that will show up in the sidebar.
    </div>
```

### Example 2:

**mock_data.yml:**

```yaml
    main: |
        <div>I've <strong>got</strong> some html</div>
        <p>Notice the pipe (|) trailing main, it tells YAML that HTML is going to follow.</p>
    sidebar:  |
        <div>I also have some html, you could do some lists:</div>
        <ul>
            <li>Item 1</li>
            <li>Item 2</li>
            <li>Item 3</li>
        </ul>
        <p>Or any other html that you might need</p>
```

**example.rhtml:**

```html
    <div class="main">
        <%= content_for(:main) -%>
    </div>
    <div class="sidebar">
        <%= content_for(:sidebar) -%>
    </div>
```

**example.rhtml output:**

```html
    <div class="main">
        <div>I've <strong>got</strong> some html</div>
        <p>Notice the pipe trailing main, it tells YAML that HTML is going to follow.</p>
    </div>
    <div class="sidebar">
        <div>I also have some html, you could do some lists:</div>
        <ul>
            <li>Item 1</li>
            <li>Item 2</li>
            <li>Item 3</li>
        </ul>
        <p>Or any other html that you might need</p>
    </div>
```

### Advance Example (blogs):

**mock_data.yml

```yaml
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
```

**Example explanation:**

In the above example there are many things going on that you may find useful.

*blog_articles* key fills in for `<%= blog_engine %>` tag.

No longer will you get an error message associated with a `<%= blog_engine %>` tag in mock_builder.  Instead now you can fill the view with actual content, or auto generated content.

*- article* key is required to use the `blog_article` key.  Each article contains the basic items needed to generate a `blog_article` in Mock Builder.

*author* key is a compound key, it requires two sub keys (`first_name`, `last_name`).

*paragraph_count* key controls how many auto generated paragraphs you want for the article, however it depends on the following key to tell mock builder if it is being used.

*body_html* key can have 2 switch states.  If the switch is marked `false`, then the body html for the article will use Lorem Ipsum prefill and the paragraph count.  If the switch state is a pipe character (|) then it will expect provided custom HTML to follow.

*created_on* key is for the date in which the article was created.  This field can take human language and translate it to a date object.  If you type *2 days ago* Mock Builder is smart enough to create a date based on todays date.  You could also type `02/12/2014 at noon` and it will correctly create a date.

*published_on* key is the same as `created_on`, however for the `published_on` field.  Currently mock builder is not smart enough to order the articles by their `published_on` date.