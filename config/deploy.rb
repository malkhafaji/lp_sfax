# config valid only for current version of Capistrano
#lock '3.9.1'
set :application, 'fax_service'
set :repo_url, 'git@github.com:malkhafaji/lp_sfax.git'

# If the environment differs from the stage name
set :migration_role, []

set :assets_roles, []
# Defaults to false
# Skip migration if files in db/migrate were not modified
# set :conditionally_migrate, true

set :keep_assets, 2
# Default branch is :master
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/var/www/apps/fax_service'

set :linked_files, %w{config/application.yml config/database.yml lib/fax/servers.yml}
# Default value for :pty is false
set :pty, true
