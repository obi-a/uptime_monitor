uptime_monitor (Hercules)
==========================
[![Build Status](https://travis-ci.org/obi-a/uptime_monitor.png?branch=master)](https://travis-ci.org/obi-a/uptime_monitor)

Uptime_monitor is a [ragios](https://github.com/obi-a/ragios) plugin that uses a real web browser to perform transactions on a website to  ensure that features of the site are still working correctly. It can check elements of a webpage to ensure they still exist and it can also perform transactions like a website login to ensure that the process still works correctly.

##Requirements
[Ragios](https://github.com/obi-a/ragios)

##Installation:
 Add the uptime_monitor to your ragios Gemfile
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
```
plugin: "uptime_monitor"
```

###Browsers
Browsers are added to the monitor using the browser key
```
browser: ["firefox"]
```
Supported browsers include Firefox, Chrome, Safari and Phantomjs. Other browsers can be specified as
```
browser: ["chrome"]
browser: ["safari"]
browser: ["phantomjs"]
```
uptime_monitor uses [Watir Webdriver](http://watirwebdriver.com), firefox runs out of the box with no configuration requried. To use Chrome or Safari see the Watir Webdriver documentation on downloading the appropriate driver binary and configuration.

By default, the browsers don't run headless, to run the browser headless, you can specify it in the format below:
```
browser: ["firefox", headless: true]
```
This will run firefox as a headless browser. You should have [Xvfb](https://en.wikipedia.org/wiki/Xvfb) installed to run a non-headless browsers as headless. Headless browsers like Phantomjs don't require Xvfb.

You can also specify headless as false
```
browser: ["firefox", headless: false]
```
The above example will run firefox as a non-headless browser.

###Validations


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

###Supported browsers:
Firefox, Chrome, Safari, Phantomjs

### Browser Format:
<pre lang="ruby">
browser: ["firefox", headless: true]
browser: ["firefox", headless: false]
browser: ["firefox"]
browser: ["chrome"]
</pre>
Running a browser headless requires xvfb installed.

###More details coming soon
