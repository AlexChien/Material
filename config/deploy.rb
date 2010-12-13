set :stages, %w(staging production)
set :default_stage, "production"
require 'capistrano/ext/multistage'
# require 'thinking_sphinx/deploy/capistrano'
# require 'thinking_sphinx/recipes/thinking_sphinx'