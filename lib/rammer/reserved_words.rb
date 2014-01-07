=begin
**************************************************************************
* The MIT License (MIT)

* Copyright (c) 2013-2014 QBurst Technologies Inc.

* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:

* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.

* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.

**************************************************************************
=end

RESERVED_WORDS = [  'rammer', 
					          'viber', 
					          'test', 
					          'lib', 
					          'template', 
          					'authorization', 
          					'authentication', 
          					'app', 
          					'apis', 
          					'models', 
          					'migrate', 
          					'oauth', 
          					'oauth2',
                    'scaffold'
				          ]
AUTH_MIGRATE = [  '01_create_users.rb',
				          '02_create_sessions.rb'
			         ]
OAUTH_MIGRATE = [ '03_create_owners.rb', 
				          '04_create_oauth2_authorizations.rb', 
				          '05_create_oauth2_clients.rb'
			          ]
AUTH_MODELS = [ 'user.rb', 
                'session.rb', 
                'oauth2_authorization.rb'
              ]
OAUTH_MODELS =  [ 'oauth2_client.rb', 
                  'owner.rb'
                ]
BASE_DIR =  [ 'app', 
              'app/apis', 
              'config', 
              'db', 
              'db/migrate', 
              'app/models'
            ]          
COMMON_RAMMER_FILES = [ 'Gemfile',
                        'Gemfile.lock',
                        'Procfile',
                        'Rakefile',
                        'server.rb', 
                        'tree.rb'
                      ] 