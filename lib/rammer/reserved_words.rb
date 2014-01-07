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