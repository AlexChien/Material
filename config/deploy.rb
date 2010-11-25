set :stages, %w(staging production)
set :default_stage, "staging"
require 'capistrano/ext/multistage'
# require 'thinking_sphinx/deploy/capistrano'
# require 'thinking_sphinx/recipes/thinking_sphinx'