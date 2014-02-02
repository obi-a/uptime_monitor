uptime_monitor
==============

Website uptime monitor plugin for Ragios


##Specification:
<pre lang="ruby">
  monitor = {monitor: "My Website",
               url: "http://mysite.com",
               every: "5m",
               contact: "admin@mail.com",
               via: "email_notifier",
               plugin: "uptime_monitor",
               exists?: [ [div: {id:"test", class: "test-section"}, text: "this is a test" ], 
                          link: {class: "main-link"},
                          element: {css: "#submit-button"}
                        ],
               title?: "Welcome to my site"
            }

 ragios.add [monitor]
</pre>
