#TODO v0.1.1
- Change the test results into a single hash key with tuples for individual results
```ruby
 {:results=>[[], [], [], [], [], []]}
```
individual tuple will look like this
```ruby
[ [{"link"=>{"href"=>"https://www.southmunn.com/aboutus"}}], "exists_as_expected" ]
```
This makes the test results accessible to be evaluated by code.