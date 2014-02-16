uptime_monitor
==============

Website uptime monitor plugin for Ragios


##Specification:
Using a real web browser, this plugin checks a webpage at the specified time intervals, to ensure that the specified elements of the page are still loading correctly.
<pre lang="ruby">
  monitor = {monitor: "My Website",
               url: "http://mysite.com",
               every: "5m",
               contact: "admin@mail.com",
               via: "email_notifier",
               plugin: "uptime_monitor",
               exists?: [
                          [{div: {id:"test", class: "test-section"}}, [text: "this is a test"]],
                          [link: {class: "main-link"}],
                          [element: {css: "#submit-button"}]
                        ],
              title?: [text: "Welcome to my site"],
              browser: ["firefox", headless: true]
            }

 ragios.add [monitor]
</pre>

###Real site test:
<pre lang="ruby">
  monitor = {monitor: "About Us page",
               url: "https://www.southmunn.com/aboutus",
              title?: [text: "About Us - Website Uptime Monitoring | SouthMunn.com"],
              browser: ["firefox", headless: false],
              exists?: [
                          [{div: {class: "box_content"}}, [includes_text: "SouthMunn is a Website Uptime Monitoring SASS created and maintained by"]],
                          [img: {src: "https://fc03.deviantart.net/fs14/f/2007/047/f/2/Street_Addiction_by_gizmodus.jpg"}],
                        ],
            }
</pre>

###Supported browsers:
firefox, chrome, safari, phantomjs

### Browser Format:
<pre lang="ruby">
browser: ["firefox", headless: true]
browser: ["firefox", headless: false]
browser: ["firefox"]
browser: ["chrome"]
</pre>
Running a browser headless requires xvfb installed.

### Page title test Format:
<pre lang="ruby">
title?: [text: "Welcome to my site"]
title?: [includes_text: "to my site"]
</pre>
1. verifies that page title is the same with provided text
2. verifies that page title contains provided substring

###Inside REPL - test web pages with uptime_monitor
