set :application, "powerposm"
set :deploy_to, "/usr/local/webservice/htdocs/#{application}"
#set :use_sudo, true
set :use_sudo, false

# Whatever you set here will be taken set as the default RAILS_ENV value
# on the server. Your app and your hourly/daily/weekly/monthly scripts
# will run with RAILS_ENV set to this value.
set :rails_env, "production"

# NOTE: for some reason Capistrano requires you to have both the public and
# the private key in the same folder, the public key should have the
# extension ".pub".
ssh_options[:keys] = ["#{ENV['HOME']}/.ssh/id_rsa"]

set :scm, :git
set :scm_verbose, true
set :branch, "develop"

set :repository, "git@github.com:AlexChien/Material.git"
set :deploy_via, :remote_cache


# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

set :user, "mongrel"
set :runner, "mongrel"


# Your EC2 instances. Use the ec2-xxx....amazonaws.com hostname, not
# any other name (in case you have your own DNS alias) or it won't
# be able to resolve to the internal IP address.
# set :domain, "121.14.48.171"
set :domain, "202.109.80.180"
role :app, domain
role :web, domain
role :db, domain, :primary => true

## Add mongrel cluster support ##
require 'mongrel_cluster/recipes'
set :mongrel_conf, "#{shared_path}/config/mongrel_cluster.yml"
set :mongrel_user, "mongrel"


# add misc task here
namespace :deploy do
  
  desc "Generate database.yml and Create asset packages for production, minify and compress js and css files"
  after "deploy:update_code", :roles => [:web] do
    database_yml
    asset_packager
  end

  # add soft link script for deploy
  desc "Symlink the upload directories"
  after "deploy:symlink", :roles => [:web] do
    ## create link for shared assets
    run "mv #{deploy_to}/#{current_dir}/public/images/assets #{deploy_to}/#{current_dir}/public/images/assets_dummy"
    run "ln -nfs #{deploy_to}/#{shared_dir}/assets #{deploy_to}/#{current_dir}/public/images/assets"

    run "mv #{deploy_to}/#{current_dir}/public/xls #{deploy_to}/#{current_dir}/public/xls_dummy"
    run "ln -nfs #{deploy_to}/#{shared_dir}/xls #{deploy_to}/#{current_dir}/public/xls"

    # 过滤后的用户excel文件
    run "mv #{deploy_to}/#{current_dir}/tmp/tmp_xls #{deploy_to}/#{current_dir}/tmp/tmp_xls_dummy"
    run "ln -nfs #{deploy_to}/#{shared_dir}/tmp/tmp_xls #{deploy_to}/#{current_dir}/tmp/tmp_xls"

    run "mv #{deploy_to}/#{current_dir}/db/backup #{deploy_to}/#{current_dir}/db/backup_dummy"
    run "ln -nfs #{deploy_to}/#{shared_dir}/db/backup #{deploy_to}/#{current_dir}/db/backup"

    migrate
  end
  
  desc "Create asset packages for production, minify and compress js and css files"
  task :asset_packager, :roles => [:web] do
    run <<-EOF
cd #{release_path} && rake RAILS_ENV=staging asset:packager:build_all
EOF
  end


  desc "Generate Production database.yml"
  task :database_yml, :roles => [:web] do
    db_config = "#{shared_path}/config/database.yml.production"
    run "cp #{db_config} #{release_path}/config/database.yml"
  end

  
end

##For testing##

#namespace :develop do
# desc "Set pre_product ENV"
# task :settings, :roles => [:pre_product] do
# set :rails_env, "development"
# end
# desc "Test say hellp"
# task :hello, :roles => [:pre_product] do
# run "echo hello"
# end
  ##run task##
  #########
#end
