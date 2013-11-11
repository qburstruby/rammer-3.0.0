# GrapeGoliath

grape_goliath is a gem which creates an application with tree structure specified for a Goliath application having Grape framework.

## Installation

Install it yourself as:

    $ gem install grape_goliath

## Usage

* grape_goliath application_name
* cd application_name
* bundle install 	(To install all dependencies)
* ruby server.rb -vs 	(To run the Goliath server)

To include grape_goliath modules into application use command gog (grape on goliath):

	$ gog module <COMMAND> <MODULE_NAME>

COMMAND : 
* -p or -plugin (Plugs in the specified module)
* -u or -unplug (Unplugs the specified module)

MODULE_NAME : 
* authentication (Includes endpoint : sign_up)
* authorization  (Includes endpoint : sign_in, sign_out)
* oauth          (Includes endpoint : register_client, authorize, access_token, token, invalidate_token)

Endpoints enabled with respective module:

Authentication
* sign_up => "Enables user authentication using email, MD5 password and redirect url returning session token."

Authorization
* sign_in => "Enables user login using credentials returning session token."
* sign_out => "Enables user logout using credentials by invalidating the session token."

Oauth
* register_client => "Registers ouath client using credentials returning client details like ID, Secret hash, authorization 					  code."
* authorize => "Enables functionality for activating authorization page access."
* access_token => "Returns oauth access token for registered clients to authorized users."
* token => "Returns bearer token to registered third party clients."
* invalidate_token => "Invalidated the issued bearer token."

## Contributors

This list is open to all. You are all welcome :).

* manishaharidas (Manisha Haridas) - 
  * Github: https://github.com/manishaharidas

## Comments/Requests

If anyone has comments or questions please let me know (qbruby@qburst.com).
If you have updates or patches or want to contribute I would love to see what you have or want to add.


## Note on Patches/Pull Requests

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a future version unintentionally.
* Send me a pull request. Bonus points for topic branches.