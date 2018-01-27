uptime_monitor (Hercules)
==========================
[![Gem Version](https://badge.fury.io/rb/uptime_monitor.svg)](http://badge.fury.io/rb/uptime_monitor)


Uptime_monitor is a [ragios](https://github.com/obi-a/ragios) plugin that uses a real web browser to perform actions on a website to ensure that features of the site are still working correctly. It can check elements of a webpage to ensure they still exist and it can also perform actions like a website login to ensure that the process still works correctly. When uptime_monitor detects a problem with the website, Uptime_monitor can take a screenshot of the web page it sees, and it can also record a video of the actions it performed on the website. The video feature is not yet implemented.

## Requirements
Ruby: At least Ruby 2.4.1 or higher is recommended

[Ragios](https://github.com/obi-a/ragios)


## Installation:
 Add the uptime_monitor gem to your ragios Gemfile
 ```ruby
 gem "uptime_monitor"
 ```
Run bundle install from the ragios root directory
 ```
 bundle install
 ```
Restart ragios

To run Ragios with uptime_monitor and all its dependencies already setup and configured in Docker Compose,  See details here: [Using Maestro](https://github.com/obi-a/maestro). This is the easiest way to get Ragios and Uptime_monitor up and running.


## Usage:
A quick example, to monitor the title tag of a web page to ensure that it hasn't changed. Using [Ragios ruby client](http://www.whisperservers.com/ragios/ragios-saint-ruby/using-ragios)
```ruby
monitor = {
  monitor: "My Blog title tag",
  url: "http://obi-akubue.org",
  every: "5m",
  contact: "admin@obiora.com",
  via: "ses",
  plugin: "uptime_monitor",
  exists?: 'title.with_text("Obi Akubue")',
  browser: "firefox"
}
ragios.create(monitor)
```
The above example will create a ragios monitor that will, every 5 minutes, use firefox to visit the website url http://obi-akubue.org, and verify that the home page title tag matches the text "Obi Akubue". The validations performed are defined in the exists? key/value pair, in this statement.
```ruby
exists?: 'title.with_text("Obi Akubue")'
```
When the title tag on the web page doesn't match the text "Obi Akubue", a failure notification will be sent out to the provided contact "admin@obiora.com".

### Using the plugin
To use the uptime monitor plugin add the key/value pair to the monitor
```ruby
plugin: "uptime_monitor"
```

### Browsers
A browser is specified, by adding a browser key/value pair to the monitor
```ruby
browser: "firefox"
```
Supported browsers include Firefox, Chrome, Safari and Phantomjs. Other browsers can be specified as
```ruby
browser: "chrome"
browser: "safari"
browser: "phantomjs"
```
uptime_monitor uses [Watir](http://watir.com), to easily access the different browsers see the development section, running uptime_monitor with Selenium Grid and Docker Compose.

### Validations
To verify that a html element exists on the web page, a validation needs to be added to the monitor. Validations are specified with the exists? key/value pair which takes a string of html elements as it's value. It verifies that the html elements in the array exists on the current web page.
```ruby
exists?: "h1 div"
```
The above example will verify that a h1 and a div exists on the page.

#### HTML Elements
The simplest way to specify a html element is using the element name.
```ruby
exists?: "h1 div a img span"
```
HTML elements can also be specified with their attributes in a ruby-like syntax.
```ruby
exists?: 'div.where(class: "box_content")'
```
The above will verify that a div with class attribute equals to "box_content" exists on the page.

Other examples:
```ruby
img.where(src: "https://fc03.deviantart.net/fs14/f/2007/047/f/2/Street_Addiction_by_gizmodus.jpg")

```
Specifies an img tag with src="https://fc03.deviantart.net/fs14/f/2007/047/f/2/Street_Addiction_by_gizmodus.jpg".

```ruby
div.where(id:"test", class: "test-section")
```
Specifes a div with id="test" and class="test-section".

#### Multiple validations
Multiple validations can be added to a monitor, see below:
```ruby
validations = <<-eos
  div.where(class: "box_content")
  img.where(src: "https://fc03.deviantart.net/fs14/f/2007/047/f/2/Street_Addiction_by_gizmodus.jpg")
  div.where(id:"test", class: "test-section")
eos

monitor = {
  monitor: "My Blog title tag",
  url: "http://obi-akubue.org",
  every: "5m",
  contact: "admin@obiora.com",
  via: "ses",
  plugin: "uptime_monitor",
  exists?: validations,
  browser: "firefox"
}

ragios.create(monitor)
```
In the above example the string variable *validations* contains validations that need to be performed when the monitor runs. During execution, the monitor will visit the website and verify that all the html elements specified in the validations exists on the page, if any of them doesn't exist, a notification of the failure will be sent out.


#### Standard attributes

Only standard attributes for an element can be included in the above format *div.where(id: "test")*, for example a div has the following standard attributes id, class, lang, dir, title, align, onclick, ondblclick, onmousedown, onmouseup, onmouseover, onmousemove, onmouseout, onkeypress, onkeydown, onkeyup. So *div.where(class: "anything")* will work.

But custom or data attributes cannot be included in the same format, for example
```html
<div data-brand="toyota">
```
The following
```ruby
div.where(data-brand: "toyota")
```
will give an error because "data-brand" is not a standard attibute for div, to specify elements by data or custom attributes use css selectors, see below.


#### Using CSS Selectors
HTML elements can also be specified with css selectors.
```ruby
element.where(css: "#rss-link")
```
This specifies an element with id="rss-link".

To specify an element by data attributes
```ruby
element.where(css: "[data-brand='toyota']")
```

#### Helpers for HTML elements
Helpers are available to make some elements easier to reason about:

#####Links
An anchor tag could be specified with a link helper, this makes it more readable and easier to reason about.

Using the anchor tag
```ruby
a.where(text: "Click Here")
```

More readble using a helper
```ruby
link.where(text: "Click Here")
```

```ruby
link.where(href: "https://www.southmunn.com/aboutus")
```

##### Buttons
```ruby
button.where(id: "searchsubmit")
```

#####Text Fields
```ruby
text_field.where(id: "search")
```

More readable than the input tag
```ruby
input.where(id: "search")
```

##### Checkboxes
```ruby
checkbox.where(value: "Butter")
```
##### Radio Buttons
```ruby
radio.where(name: "group1", value: "Milk")
```

##### Drop Down menus
```html
<select name="mydropdown">
<option value="Milk">Fresh Milk</option>
<option value="Cheese">Old Cheese</option>
<option value="Bread">Hot Bread</option>
</select>
```
Helper
```ruby
select_list.where(name: "mydropdown")
```

Or HTML select tag
```ruby
select.where(name: "mydropdown")
```

Options of the drop-down menu can be specified using option
```ruby
option.where(value: "Milk")
```

#### Text Validations
A text validation is used to verify that the text content of a html element hasn't changed. For example,
```ruby
exists?: 'title.with_text("Welcome to my site")'
```
The above example first verifies that a title tag exists on the page, then it verifies that title tag text is equal to "Welcome to my site". The above example is a text validation.
Text validations can also verify that the html element's text includes the provided string:
```ruby
exists?: 'title.includes_text("Welcome")'
```
The above example verifies that the title tag's text includes the string "Welcome".
Another example, to verify that a div with class="box_content" includes the string "SouthMunn is a Website"
```ruby
exists?: 'div.where(class: "box_content").includes_text("SouthMunn is a Website")'
```
Text validations can be used on html elements that can contain text like title, div, span, h1, h2 etc.

#### Actions
Validations can also include actions. The actions are performed on the html element after it is verfied that the element exists. Example to set a text field's value
```ruby
exists?: 'text_field.where(id: "username").set("admin")'
```
The above example is an action that will set the text field's value to the string "admin".

##### Actions on html elements
Common actions performed on elements are set, select and click.

For example to set value for a textfield or textarea.
```ruby
text_field.where(name: "q").set("ruby")
text_area.where(name: "longtext").set("In a world...")
```
Select an option from a drop down menu
```html
<select name="mydropdown">
<option value="Milk">Fresh Milk</option>
<option value="Cheese">Old Cheese</option>
<option value="Bread">Hot Bread</option>
</select>
```
```ruby
select_list.where(name: "mydropdown").select("Old Cheese")
```
Click a radio button, checkbox, link or button
```ruby
radio.where(name: "group1", value: "Milk").click
checkbox.where(name: "checkbox").click
link.where(text: "Click Here").click
button.where(id: "submit").click
```
#### Waiting
For webpages that use a lot of AJAX, it's possible to wait until an element exists, by using the wait_for keyword. This keyword takes an element as value. It is a special type of validation, it will wait for 30 seconds for the provided element to exist, if the element doesn't exist in 30 seconds the validation fails.
```ruby
wait_for div.where(id: "open-section")
```
The above example will wait 30 seconds until the div exists, if it doesn't exist after 30 seconds the validation will fail.

#### Multiple validations and actions
```ruby
validations = <<-eos
  text_field.where(id: "username").set("admin")
  text_field.where(id: "password").set("pass")
  button.click
  title.includes_text("Dashboard")
eos
```
With multiple validations like the example above, the monitor will run the validations, line by line, from top to bottom. When it meets an action it will apply it on the element in the validation. The monitor fails its test if any of the validation fails. So for the monitor to pass, all validations must pass.

When actions like clicking a link, changes the current page, the following validations will be performed on the new page.

A combination of multiple validations and actions form the basis for performing transactions.


#### Performing Transactions
Transactions are achieved by a combination of multiple validations and actions.

Example, to monitor the keyword search feature on my blog, notice the validations in the exists? key's value:
```ruby
steps = <<-eos
  title.with_text("Obi Akubue")
  text_field.where(id: "s").set("ruby")
  button.where(id: "searchsubmit").click
  title.includes_text("ruby").includes_text("Search Results")
  h2.where(class: "pagetitle").includes_text("Search results for")
eos

monitor = {
  monitor: "My Blog: keyword search",
  url: "http://obi-akubue.org",
  every: "1h",
  contact: "admin@obiora.com",
  via: "ses",
  plugin: "uptime_monitor",
  exists?: steps,
  browser: "firefox"
}
ragios.create(monitor)
```
In the above example, the monitor will visit "http://obi-akubue.org" every hour, and perform a search for keyword 'ruby', then confirm that the search works by checking that the title and h2 tag of the *search results page* contains the expected text.

Another example, to search my friend's ecommerce site http://akross.net, for a citizen brand wristwatch, add the watch to cart, and go to the checkout page.

This transaction verifies the following about the site:

1. Product search is working

2. Add to cart works

3. Checkout page is reachable

4. All three above works together as a sequence

```ruby
add_items_to_cart = <<-eos
  title.with_text("All Watches Shop, Authentic Watches at Akross")
  text_field.where(name: "filter_name").set("citizen")
  div.where(class: "button-search").click
  title.with_text("search")
  link.where(text: "search")
  button.where(value: "Add to Cart").click
  link.where(text: "Checkout").click
  title.with_text("Checkout")
eos

monitor = {
  monitor: "Akross.net: Add citizen watch to cart and checkout",
  url: "http://akross.net",
  every: "1h",
  contact: "admin@obiora.com",
  via: "ses",
  plugin: "uptime_monitor",
  exists?: add_items_to_cart,
  browser: "firefox"
}


ragios.create(monitor)
```

Another example, to monitor the login process of the website http://southmunn.com
```ruby
login_process = <<-eos
  title.with_text("Website Uptime Monitoring | SouthMunn.com")
  link.where(text: "login").click
  title.with_text("Sign in - Website Uptime Monitoring | SouthMunn.com")
  text_field.where(id: "username").set("admin")
  text_field.where(id: "password").set("pass")
  button.click
  title.with_text("Dashboard - Website Uptime Monitoring | SouthMunn.com")
eos

monitor = {
  monitor: "My Website login processs",
  url: "https:/southmunn.com",
  every: "1h",
  contact: "admin@obiora.com",
  via: "email_notifier",
  plugin: "uptime_monitor",
  exists?: login_process,
  browser: "firefox"
}

ragios.create(monitor)
```

## Running Uptime Monitor outside Ragios with Docker Compose

First clone the uptime_monitor Repo on github.

```
git clone git@github.com:obi-a/uptime_monitor.git
```

Change to the uptime_monitor directory:
```
cd uptime_monitor
```

Build the docker containers:
```
docker-compose build
```
This builds the uptime_monitor container

Load the uptime_monitor into PRY console in a container:
```
docker-compose run  --rm uptime_monitor
```
This will give you access to the entire uptime_monitor and all its objects loaded into PRY console. It will also run Selenium Grid and firefox in separate docker containers already connected to the uptime_monitor.


## Testing the validations outside Ragios
Sometimes it's useful to run validations outside Ragios to verify that the validations are syntactically correct and don't raise any exceptions. This is best done by running the uptime_monitor plugin as a Plain Old Ruby Object.

First load uptime_monitor into PRY console:
```
docker-compose run uptime_monitor
```
From the console you can load the uptime_monitor directly:

```ruby
monitor = {
  url: "http://obi-akubue.org",
  browser: "firefox",
  exists?: "title div"
}

u = Ragios::Plugins::UptimeMonitor.new
u.init(monitor)
u.test_command?
# => true
u.test_result
#=> {
#     :results =>
#       [
#         ["title", "exists_as_expected"],
#         ["div", "exists_as_expected"]
#       ]
#   }

# test result for a failed test during downtime
monitor = {
  url: "http://obi-akubue.org",
  browser: "firefox",
  exists?: 'title.with_text("something")'
}

u.init(monitor)
u.test_command?
# => false
u.test_result
# => {
#     :results =>
#       [
#         ["title, with text \"something\"", "does_not_exist_as_expected"]
#       ]
#   }
```
In the above example the *test_command?* method runs the validations and returns true when all validations passes, returns false when any of the validation fails. *test_result* is a hash that contains the result of the tests ran by *test_command?*.


## Testing individual validations
It can be very useful to test validations/actions individually before adding them to Ragios. This can be done by running plugin's browser directly.
```ruby
url= "http://obi-akubue.org"
browser_name = "firefox"
browser = Hercules::Maestro::Browser.new(url, browser_name)

browser.exists? 'title.includes_text("ruby")'

browser.exists? 'text_field.where(id: "s").set("ruby")'

browser.exists? 'checkbox.where(name: "checkbox").click'

browser.close
```
The above example will launch firebox and open the provided url. The `exists?` method takes a single validation/action as parameter and performs the validation on the current page, it returns true if the validation passes and returns false if the validation fails. In the first validation
```
browser.exists? 'title.includes_text("ruby")'
```
it checks if the title tag on the current webpage includes the text 'ruby'.


## Screenshots
The uptime_monitor can be configured to take a screenshot of the webpage when a test fails. This screenshot is uploaded to Amazon s3 and its url is included in the test_result. So the website admin can see what the site looks like when transaction failed.

This feature is disable by default, to enable it set following environment variable.
```
RAGIOS_HERCULES_ENABLE_SCREENSHOTS=true
```
Also set environment variables for the Amazon s3 account you want to use for storing the screenshots,
```
AWS_ACCESS_KEY_ID=xxxxxxx
AWS_SECRET_ACCESS_KEY=xxxxxx
RAGIOS_HERCULES_S3_DIR=xxxxxx
```
The above env vars are for the Amazon AWS access key, AWS secret key and s3 directory/bucket you want to use for storage. First create this s3 bucket manually.

With the screenshots feature enabled, the results of a failed test will include a screenshot of the webpage when the test failed.
See an example below:
```ruby
monitor = {
  url: "http://obi-akubue.org",
  browser: "firefox",
  exists?: 'title.with_text("dont_exist")'
}

u = Ragios::Plugins::UptimeMonitor.new
u.init(monitor)
u.test_command?
#=>false
u.test_result
#=>  {
#      :results=>
#        [
#          ["title, with text \"dont_exist\"", "does_not_exist_as_expected"]
#        ],
#      :screenshot=>
#        "https://screenshot-ragios.s3.amazonaws.com/uploads/screenshot1428783237.png"
#    }
```
Notice that *test_result* includes a url to the screenshot  of the webpage when the test failed. This test result is also included in the notifications sent to site admin by Ragios when a test fails. So this way the admin can see exactly what webpage looked like when the transaction failed.

## Disable screenshots on individual monitors
While using Ragios, to disable screenshots on a particular monitor add the key/value pair ```disable_screenshots: true```
example:
```ruby
monitor = {
  url: "http://obi-akubue.org",
  browser: "firefox",
  exists?: "title",
  disable_screenshots: true
}

ragios.create(monitor)
```
This will diable screenshots only for this monitor, no screenshots will be taken when its test fails.

### To run all the unit tests
```
docker-compose run  --rm unit_tests
```

## License:
MIT License.

Copyright (c) 2017 Obi Akubue, obi-akubue.org
