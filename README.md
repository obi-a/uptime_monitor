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
                          [div: {id:"test", class: "test-section"}, text: "this is a test" ],
                          [link: {class: "main-link"}],
                          [element: {css: "#submit-button"}]
                        ],
              title?: [text: "Welcome to my site"],
              browser: ["firefox", headless: true]
            }

 ragios.add [monitor]
</pre>

Supported browsers:
firefox, chrome, safari, phantomjs
