<img height="100" width="250" src="https://raw.github.com/qburstruby/rammer/master/rammer_logo.png">

[![Gem Version](https://badge.fury.io/rb/rammer.png)](http://badge.fury.io/rb/rammer)  [![Build Status](https://travis-ci.org/qburstruby/rammer-3.0.0.svg?branch=master)](https://travis-ci.org/qburstruby/rammer-2.0.0)

Rammer is a framework dedicated to build high performance Async API servers on top of non-blocking (asynchronous) Ruby web server called Goliath. Rammer APIs are designed on top of REST-like API micro-framework Grape. Rammer is modular and integrates a powerful CLI called Viber to plug in and out its modules.

## Installation

Install it yourself as:

    $ gem install rammer

## Usage

* rammer application_name
* cd application_name
* bundle install 	(To install all dependencies)
* ruby server.rb -vs 	(To run the Goliath server)

To include rammer modules into application use command viber:

	$ viber module <COMMAND> <MODULE_NAME>

COMMAND : 
* -p or -plugin (Plugs in the specified module)
* -u or -unplug (Unplugs the specified module)

MODULE_NAME : 
* authentication (Includes endpoint : sign_up)
* authorization  (Includes endpoint : sign_in, sign_out)
* oauth          (Includes endpoint : register_client, authorize, access_token, token, invalidate_token)

Endpoints enabled with respective module:

Authentication
* sign_up 			: "Enables user authentication using email, MD5 password and redirect url returning session token."

Authorization
* sign_in 			: "Enables user login using credentials returning session token."
* sign_out 			: "Enables user logout using credentials by invalidating the session token."

Oauth
* authenticate 	    : "Registers ouath client using credentials returning client details like ID, Secret hash, authorization code."
* request_token     : "Returns a request token which is further used for access token generation."
* authorize 		: "Enables functionality for activating authorization page access."
* access_token 		: "Returns oauth access token for registered clients to authorized users."
* token 			: "Returns bearer token to registered third party clients."
* invalidate_token 	: "Invalidated the issued bearer token."

To generate a scaffold structure in rammer use the command:

	$ rammer g/generate scaffold <scaffold_name> <field_name:type>

## Wiki Link

For further details visit our wiki link :

https://github.com/qburstruby/rammer-2.0.0/wiki

## Contributors

This list is open to all. You are all welcome :).

* manishaharidas (Manisha Haridas) - 
  * Github: https://github.com/manishaharidas

* qburstruby (QBurst Ruby Team) - 
  * Github: https://github.com/qburstruby

## Comments/Requests

If anyone has comments or questions please let me know (qbruby@qburst.com).
If you have updates or patches or want to contribute I would love to see what you have or want to add.


## Note on Patches/Pull Requests

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a future version unintentionally.
* Send me a pull request. Bonus points for topic branches.
