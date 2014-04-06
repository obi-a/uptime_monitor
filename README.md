uptime_monitor (Hercules)
==========================
[![Build Status](https://travis-ci.org/obi-a/uptime_monitor.png?branch=master)](https://travis-ci.org/obi-a/uptime_monitor)

Uptime_monitor is a [ragios](https://github.com/obi-a/ragios) plugin that uses a real web browser to perform transactions on a website to  ensure that features of the site are still working correctly. It can check elements of a webpage to ensure they still exist and it can also perform transactions like a website login to ensure that the process still works correctly.

##Requirements
[Ragios](https://github.com/obi-a/ragios)

##Installation:
 Add the uptime_monitor gem to your ragios Gemfile
 ```ruby
 gem "uptime_monitor"
 ```
Run bundle install from the ragios root directory
 ```
 bundle install
 ```
Restart ragios

##usage:
A quick example, to monitor the title tag of a web page to ensure that it hasn't changed. Using [Ragios ruby client](http://www.whisperservers.com/ragios/ragios-saint-ruby/using-ragios)
````ruby
monitor = {monitor: "My Blog title tag",
            url: "http://obi-akubue.org",
            every: "5m",
            contact: "admin@obiora.com",
            via: "gmail_notifier",
            plugin: "uptime_monitor",
            exists?: [
                       [:title, [text: "Obi Akubue"]]
                     ],
            browser: ["firefox"]
          }
ragios.add [monitor]
```
The above example will create a ragios monitor that will, every 5 minutes, use firefox to visit the website url http://obi-akubue.org, and verify that the title tag on the page matches the text "Obi Akubue".

###Using the plugin
To use the uptime monitor plugin add the key/value pair to the monitor
```ruby
plugin: "uptime_monitor"
```

###Browsers
The browser to use is specified, by adding a browser key/value pair to the monitor
```ruby
browser: ["firefox"]
```
Supported browsers include Firefox, Chrome, Safari and Phantomjs. Other browsers can be specified as
```ruby
browser: ["chrome"]
browser: ["safari"]
browser: ["phantomjs"]
```
uptime_monitor uses [Watir Webdriver](http://watirwebdriver.com), firefox runs out of the box with no configuration requried. To use Chrome or Safari see the Watir Webdriver documentation on downloading the appropriate driver binary and configuration.

By default, the browsers don't run headless, to run the browser headless, you can specify it in the format below:
```ruby
browser: ["firefox", headless: true]
```
This will run firefox as a headless browser. You should have [Xvfb](https://en.wikipedia.org/wiki/Xvfb) installed to run a non-headless browsers as headless. Headless browsers like Phantomjs don't require Xvfb.

You can also specify headless as false
```ruby
browser: ["firefox", headless: false]
```
The above example will run firefox as a non-headless browser.

###Validations
To verify that a html element exists on the web page, a validation needs to be added to the monitor. Validations are specified with the exists? key/value pair which takes an array of html elements as it's value. It verifies that the html elements in the array exists on the current web page.
```ruby
exists?: [
           [:h1]
           [:div]
         ]
```
The above example will verify that an h1 and a div exists on the page.

####HTML Elements
The simplest way to specify a html element is using a symbol.
```ruby
exists?: [
           [:h1]
           [:div]
           [:a]
           [:img]
           [:span]
         ]
```
HTML elements can also be specified as a hash with their name as key and attributes as value.
```ruby
exists?: [
            [div: {class: "box_content"}]
         ]
```
The above will verify that a div with class "box_content" exists on the page.

Other examples:
```ruby
[img: {src: "https://fc03.deviantart.net/fs14/f/2007/047/f/2/Street_Addiction_by_gizmodus.jpg"}]

```
Specifies an img tag with src="https://fc03.deviantart.net/fs14/f/2007/047/f/2/Street_Addiction_by_gizmodus.jpg".

```ruby
[div: {id:"test", class: "test-section"}]
```
Specifes a div with id="test" and class="test-section".

####Standard attributes

Only standard attributes for an element can be included in the hash, for example a div can only include all or any of the following attributes id, class, lang, dir, title, align, onclick, ondblclick, onmousedown, onmouseup, onmouseover, onmousemove, onmouseout, onkeypress, onkeydown, onkeyup.

Custom or data attributes cannot be included, for example to specify a div by data attributes, for example
```html
<div data-brand="toyota">
```
The following
```ruby
[div: {"data-brand" => "toyota"}]
```
will give an error because "data-brand" is not a standard attibute for div, to specify elements by data or custom attributes use css selectors, see below.


####Using CSS Selectors
HTML elements can also be specified with css selectors.
```ruby
[element: {css: '#rss-link'}]
```
This specifies an element with id="rss-link".

To specify an element by data attributes
```ruby
[element: {css: '[data-brand="toyota"]'}]
```

####Helpers for HTML elements
Helpers are available to make some elements easier to reason about:

#####Links
An anchor tag could be specified by a link, this makes it more readable and easier to reason about
Using the anchor tag
```ruby
[a: {text: "Click Here"}]
```

More readble using helper
```ruby
[link: {text: "Click Here"}]
```

```ruby
[link: {href: "https://www.southmunn.com/aboutus"}]
```

#####Buttons
```ruby
[button: {id: "searchsubmit"}]
```

#####Text Fields
```ruby
[text_field: {id: "search"}]
```

More readable than the input tag
```ruby
[input: {id: "search", type: "text"}]
```

#####Checkbox
```ruby
[checkbox: {value: "Butter"}]
```
#####Radio Buttons
```ruby
[radio: {name: "group1", value: "Milk"}]
```

######Drop Down menus
```html
<select name="mydropdown">
<option value="Milk">Fresh Milk</option>
<option value="Cheese">Old Cheese</option>
<option value="Bread">Hot Bread</option>
</select>
```
Helper
```ruby
[select_list: {name: "mydropdown"}]
```

Or HTML select tag
```ruby
[select: {name: "mydropdown"}]
```

Options of the drop-down menu can be specified using option
```ruby
[option: {value: "Milk"}]
```

####Text Validations

... more documentation coming soon

##Specification:

<pre lang="ruby">
monitor = {monitor: "My Website",
            url: "http://mysite.com",
            every: "5m",
            contact: "admin@mail.com",
            via: "email_notifier",
            plugin: "uptime_monitor",
            exists?: [
                        [:title, [text: "Welcome to my site"]],
                        [{div: {id:"test", class: "test-section"}}, [text: "this is a test"]],
                        [a: {href: "/aboutus" }],
                        [:h1],
                        [:h2,[text: "Login"]],
                        [form: {action: "/signup", method: "get"}],
                        [{element: {css: "#submit-button"}}, [:click]],
                        [{text_field: {id: "username"}}, [set: "admin"]],
                        [{text_field: {id: "password"}}, [set: "pass"]],
                        [link: {text: "Contact Us"}],
                        [wait_until_exists?: [div: {id:"open-section"}]]
                     ],
            browser: ["firefox", headless: true]
          }
ragios.add [monitor]
</pre>

###Monitor login process of a real site
<pre lang="ruby">
login_process = [
                    [:title, [text: "Website Uptime Monitoring | SouthMunn.com"]],
                    [{link: {text:"Login"}}, [:click]],
                    [:title, [text: "Sign in - Website Uptime Monitoring | SouthMunn.com"]],
                    [{text_field: {id: "username"}}, [set: "admin"]],
                    [{text_field: {id: "password"}}, [set: "pass"]],
                    [:button, [:click]],
                    [:title, [text: "Dashboard - Website Uptime Monitoring | SouthMunn.com"]]
                ]

monitor = {monitor: "My Website",
            url: "https:/southmunn.com",
            every: "5m",
            contact: "admin@mail.com",
            via: "email_notifier",
            plugin: "uptime_monitor",
            exists?: login_process,
            browser: ["firefox", headless: true]
          }
ragios.add [monitor]
</pre>

###Real site test:
<pre lang="ruby">
monitor = {monitor: "About Us page",
            url: "https://www.southmunn.com/aboutus",
            browser: ["firefox", headless: false],
            exists?: [
                        [{div: {class: "box_content"}}, [includes_text: "SouthMunn is a Website Uptime Monitoring SASS created and maintained by"]],
                        [img: {src: "https://fc03.deviantart.net/fs14/f/2007/047/f/2/Street_Addiction_by_gizmodus.jpg"}],
                     ],
          }

u = Ragios::Plugin::UptimeMonitor.new
u.init monitor
u.test_command?
#=> true
u.test_result
#=> {[{:div=>{:class=>"box_content"}},
#  [{:includes_text=>
#     "SouthMunn is a Website Uptime Monitoring SASS created and maintained by"}]]=>
#  :exists_as_expected,
# [{:img=>
#    {:src=>
#      "https://fc03.deviantart.net/fs14/f/2007/047/f/2/Street_Addiction_by_gizmodus.jpg"}}]=>
#  :exists_as_expected}


#test result during downtime
u.test_command?
#=> false
u.test_result
#=> {[{:div=>{:class=>"box_content"}},
#  [{:includes_text=>
#     "SouthMunn is a Website Uptime Monitoring SASS created and maintained by"}]]=>
#  :does_not_exist_as_expected,
# [{:img=>
#    {:src=>
#      "https://fc03.deviantart.net/fs14/f/2007/047/f/2/Street_Addiction_by_gizmodus.jpg"}}]=>
#  :does_not_exist_as_expected}
</pre>

###More details coming soon
