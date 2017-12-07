# server-based syntax
# ======================
# Defines a single server with a list of roles and multiple properties.
# You can define all roles on a single server, or split them:
server '54.209.151.121', user: 'deploy', roles: %w{app db web}, my_property: :my_value
set :rails_env, 'development'
