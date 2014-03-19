uptime_monitor (Hercules)
==========================
Using a real web browser, this plugin checks pages of a website at the specified time intervals, to ensure that the specified elements of the pages and features of the site are still working correctly.

[![Build Status](https://travis-ci.org/obi-a/uptime_monitor.png?branch=master)](https://travis-ci.org/obi-a/uptime_monitor)

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
