[![Build Status](https://travis-ci.org/amcaplan/simple_jsonapi_client.svg?branch=master)](https://travis-ci.org/amcaplan/simple_jsonapi_client)
[![Gem Version](https://badge.fury.io/rb/simple_jsonapi_client.svg)](https://badge.fury.io/rb/simple_jsonapi_client)

# What is `SimpleJSONAPIClient`?

`SimpleJSONAPIClient` is a framework for building Ruby clients for JSONAPI-compliant services.  

# How do I use `SimpleJSONAPIClient`?

## Setup

First create models inheriting from `SimpleJSONAPIClient::Base`, and specifying a few details.

* `COLLECTION_URL` - the path to fetch the resource collection
* `INDIVIDUAL_URL` - the path to fetch an individual resource
* `TYPE` - the JSONAPI resource type to use when creating a new resource
* `attributes` - the names of attributes which can be found on the resource
* relationships - `has_one` and `has_many` define relationships, and take these arguments:
  * relationship name (e.g., the `:goats` in `has_many :goats`)
  * `class_name` to use when instantiating related objects

They should look like this:

```ruby
class Post < SimpleJSONAPIClient::Base
  COLLECTION_URL = '/posts'
  INDIVIDUAL_URL = '/posts/%{id}'
  TYPE = 'posts'

  attributes :title, :text
  meta :copyright

  has_one :author, class_name: 'Author'
  has_many :comments, class_name: 'Comment'
end

class Author < SimpleJSONAPIClient::Base
  COLLECTION_URL = '/authors'
  INDIVIDUAL_URL = '/authors/%{id}'
  TYPE = 'authors'

  attributes :name

  has_many :posts, class_name: 'Post'
  has_many :comments, class_name: 'Comment'
end

class Comment < SimpleJSONAPIClient::Base
  COLLECTION_URL = '/comments'
  INDIVIDUAL_URL = '/comments/%{id}'
  TYPE = 'comments'

  attributes :text

  has_one :post, class_name: 'Post'
  has_one :author, class_name: 'Author'
end
```

If you have behavior you'd like to share across models, you may want to first create an abstract class inheriting from `SimpleJSONAPIClient::Base` and then have all your models inherit from that.

Next, create a [`Faraday`](https://github.com/lostisland/faraday) connection to handle the domain, authorization strategy, and anything else you need (making sure to include [JSON parsing middleware](https://github.com/lostisland/faraday_middleware/wiki/Parsing-responses)):

```ruby
def connection(token)
  default_headers = {
    'Accept' => 'application/vnd.api+json',
    'Content-Type' => 'application/vnd.api+json',
    'Authorization' => "token=#{token}"
  }

  @connection ||= Faraday.new(url: 'https://example.com', headers: default_headers) do |connection|
    connection.request :json
    connection.response :json, :content_type => /\bjson$/ # use middleware to parse JSON when response Content-Type is json
    connection.adapter :net_http
  end
end
```

Now you can start making requests!

## Fetching

### Laziness and `SimpleJSONAPIClient`

```ruby
Post.fetch_all(connection: connection)
=> #<Enumerator: #<Enumerator::Generator:0x00562894acd420>:each>
```

What's going on?  `SimpleJSONAPIClient` tries to be as lazy as possible while still being convenient.  So if you actually want to fetch everything, you'll be able to call `Array` methods and it will fetch the resource, paginating through all the results.  If it's an endpoint with thousands of pages, you can use `Enumerator` methods like `#each` and it'll paginate through the results, fetching the next page when it runs out of objects.

Let's call `#to_a` to see a bit more detail.

```ruby
posts = Post.fetch_all(connection: connection).to_a
=> [#<Post id=1 title="A Very Proper Post Title" text="I am absolutely incensed about something." author=#<SimpleJSONAPIClient::Base::SingularLinkRelationship model_class=Author url=http://jsonapi_app:3000/posts/1/author> comments=#<SimpleJSONAPIClient::Base::ArrayLinkRelationship model_class=Comment url=http://jsonapi_app:3000/posts/1/comments>>,
 #<Post id=2 title="The System is Down" text="The Cheat" author=#<SimpleJSONAPIClient::Base::SingularLinkRelationship model_class=Author url=http://jsonapi_app:3000/posts/2/author> comments=#<SimpleJSONAPIClient::Base::ArrayLinkRelationship model_class=Comment url=http://jsonapi_app:3000/posts/2/comments>>]
```

Attributes are loaded immediately, but relationships are lazily instantiated.  So if we dig a little bit further:

```ruby
posts.first.author
=> #<SimpleJSONAPIClient::Base::SingularLinkRelationship model_class=Author url=http://jsonapi_app:3000/posts/1/author>
```

Nope, still lazy!  However, once we start fetching details about the author, `SimpleJSONAPIClient` knows a request has to be made, and fills in the details:

```ruby
posts.first.author.id
=> "3"

posts.first.author
=> #<Author id=3 name="Filbert" posts=#<SimpleJSONAPIClient::Base::ArrayLinkRelationship model_class=Post url=http://jsonapi_app:3000/authors/3/posts> comments=#<SimpleJSONAPIClient::Base::ArrayLinkRelationship model_class=Comment url=http://jsonapi_app:3000/authors/3/comments>>
```

We can read more easily by calling `#as_json`:

```ruby
posts.first.author.as_json
=> {
  :data => {
    :type => "authors",
    :attributes => { :name => "Filbert" },
    :relationships => {
      :posts => {
        :data => [{ :type => "posts", :id => "1" }]
      },
      :comments => { :data => [] }
    }
  }
}
```

### More About Fetching Capabilities

You can also explicitly fetch a single item:

```ruby
post = Post.fetch(connection: connection, url_opts: { id: 1 })
=> #<Post id=1 title="A Very Proper Post Title" text="I am absolutely incensed about something." author=#<SimpleJSONAPIClient::Base::SingularLinkRelationship model_class=Author url=http://jsonapi_app:3000/posts/1/author> comments=#<SimpleJSONAPIClient::Base::ArrayLinkRelationship model_class=Comment url=http://jsonapi_app:3000/posts/1/comments>>
```

`url_opts`, in all cases where you see them, are passed to the template Strings for `INDIVIDUAL_URL` and `COLLECTION_URL` in the model.

You've already seen that `id` and `relationships` are available; `attributes` and `meta` information also become methods on the object:

```ruby
post = Post.fetch(connection: connection, url_opts: { id: 1 })
post.title
=> "A Very Proper Post Title"
post.text
=> "I am absolutely incensed about something."
post.copyright
=> "Copyright 2017"
```

You can also use JSONAPI includes to reduce the number of requests that are necessary:

```ruby
post = JSONAPIAppClient::Post.fetch(connection: connection, url_opts: { id: 1 }, includes: ['author', 'comments.author'])
post.author # will not make another web request
post.comments.first.author # will not make another web request
```

`SimpleJSONAPIClient` will check the included records for related records you access through the returned model.

And finally, you can use JSONAPI-style filtering as well:

```ruby
JSONAPIAppClient::Author.fetch_all(connection: connection, filter_opts: { name: 'Filbert' }).to_a
=> [#<JSONAPIAppClient::Author id=1 name="Filbert" posts=#<SimpleJSONAPIClient::Relationships::ArrayLinkRelationship model_class=JSONAPIAppClient::Post url=http://jsonapi_app_console:3002/authors/1/posts> comments=#<SimpleJSONAPIClient::Relationships::ArrayLinkRelationship model_class=JSONAPIAppClient::Comment url=http://jsonapi_app_console:3002/authors/1/comments>>]
```

## Creating

Creating records is available from the model class:

```ruby
post = Post.fetch(url_opts: { id: 1 }, connection: connection)
=> #<Post id=1 title="A Very Proper Post Title" text="I am absolutely incensed about something." author=#<SimpleJSONAPIClient::Base::SingularLinkRelationship model_class=Author url=http://jsonapi_app:3000/posts/1/author> comments=#<SimpleJSONAPIClient::Base::ArrayLinkRelationship model_class=Comment url=http://jsonapi_app:3000/posts/1/comments>>
author = Author.fetch(url_opts: { id: 1}, connection: connection)
=> #<Author id=1 name="Filbert" posts=#<SimpleJSONAPIClient::Base::ArrayLinkRelationship model_class=Post url=http://jsonapi_app:3000/authors/1/posts> comments=#<SimpleJSONAPIClient::Base::ArrayLinkRelationship model_class=Comment url=http://jsonapi_app:3000/authors/1/comments>>

Comment.create(connection: connection, text: 'I adore your article!', post: post, author: author)
=> #<Comment id=19 text="I adore your article!" post=#<SimpleJSONAPIClient::Base::SingularLinkRelationship model_class=Client::Post url=http://jsonapi_app:3000/comments/19/post> author=#<SimpleJSONAPIClient::Base::SingularLinkRelationship model_class=Author url=http://jsonapi_app:3000/comments/19/author>>
```

The created record is returned; if creation fails, a `SimpleJSONAPIClient::Errors::ApiError` is raised.

## Updating

If you want to update a record, you can do it from the model itself:

```ruby
post = Post.fetch(url_opts: { id: 1 }, connection: connection)
=> #<Post id=1 title="A Very Proper Post Title" text="I am absolutely incensed about something." author=#<SimpleJSONAPIClient::Base::SingularLinkRelationship model_class=Author url=http://jsonapi_app:3000/posts/1/author> comments=#<SimpleJSONAPIClient::Base::ArrayLinkRelationship model_class=Comment url=http://jsonapi_app:3000/posts/1/comments>>
[2] pry(main)> post.update(attributes: { text: 'foo' })
=> #<Post id=1 title="A Very Proper Post Title" text="foo" author=#<SimpleJSONAPIClient::Base::SingularLinkRelationship model_class=Author url=http://jsonapi_app:3000/posts/1/author> comments=#<SimpleJSONAPIClient::Base::ArrayLinkRelationship model_class=Comment url=http://jsonapi_app:3000/posts/1/comments>>
```

If you have the ID of the record handy, you update straight from the model class without fetching the record first:

```ruby
Post.update(id: 1, url_opts: { id: 1 }, connection: connection, text: 'foo')
=> #<Post id=1 title="A Very Proper Post Title" text="foo" author=#<SimpleJSONAPIClient::Base::SingularLinkRelationship model_class=Author url=http://jsonapi_app:3000/posts/1/author> comments=#<SimpleJSONAPIClient::Base::ArrayLinkRelationship model_class=Comment url=http://jsonapi_app:3000/posts/1/comments>>
```

## Deleting

You can delete a record from the model itself:

```ruby
post = Post.fetch(url_opts: { id: 1 }, connection: connection)
=> #<Post id=1 title="A Very Proper Post Title" text="I am absolutely incensed about something." author=#<SimpleJSONAPIClient::Base::SingularLinkRelationship model_class=Author url=http://jsonapi_app:3000/posts/1/author> comments=#<SimpleJSONAPIClient::Base::ArrayLinkRelationship model_class=Comment url=http://jsonapi_app:3000/posts/1/comments>>

post.delete
=> true
Post.fetch(url_opts: { id: 1 }, connection: connection)
=> nil
```

or from the class, if you have the ID:

```ruby
Post.delete(url_opts: { id: 1 }, connection: connection)
=> true
Post.fetch(url_opts: { id: 1 }, connection: connection)
=> nil
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'simple_jsonapi_client'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install simple_jsonapi_client

## Development

You must have [Docker](https://docker.com) and [Docker Compose](https://docs.docker.com/compose/) installed to run the tests and use the built-in development utilities.

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment, and `bin/rails` to interact with the Rails app in `spec/jsonapi_app` that is provided for local development and testing.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/amcaplan/simple_jsonapi_client. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the SimpleJsonapiClient project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/amcaplan/simple_jsonapi_client/blob/master/CODE_OF_CONDUCT.md).
