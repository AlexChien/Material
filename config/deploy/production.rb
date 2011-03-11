set :application, "powerposm"
set :domain,      "69.164.193.254"
set :repository,  "git@github.com:AlexChien/Material.git"
set :use_sudo,    false
set :deploy_to,   "/var/local/www/#{application}"
set :scm,         "git"
set :user,        "runner"
set :runner,      "nobody"

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
set :branch, "master"
set :deploy_via, :remote_cache

role :app, domain
role :web, domain
role :db,  domain, :primary => true

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

    run "ln -nfs #{deploy_to}/#{shared_dir}/ext-3.3.1 #{deploy_to}/#{current_dir}/public/ext-3.3.1"

    run "mv #{deploy_to}/#{current_dir}/public/xls #{deploy_to}/#{current_dir}/public/xls_dummy"
    run "ln -nfs #{deploy_to}/#{shared_dir}/xls #{deploy_to}/#{current_dir}/public/xls"

    # 过滤后的用户excel文件
    # run "mv #{deploy_to}/#{current_dir}/tmp/tmp_xls #{deploy_to}/#{current_dir}/tmp/tmp_xls_dummy"
    # run "ln -nfs #{deploy_to}/#{shared_dir}/tmp/tmp_xls #{deploy_to}/#{current_dir}/tmp/tmp_xls"

    run "mv #{deploy_to}/#{current_dir}/db/backup #{deploy_to}/#{current_dir}/db/backup_dummy"
    run "ln -nfs #{deploy_to}/#{shared_dir}/db/backup #{deploy_to}/#{current_dir}/db/backup"

    migrate
  end

  desc "Create asset packages for production, minify and compress js and css files"
  task :asset_packager, :roles => [:web] do
    run <<-EOF
    cd #{release_path} && rake RAILS_ENV=production asset:packager:build_all
    EOF
  end

  task :start, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end

  task :stop, :roles => :app do
    # Do nothing.
  end

  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end


  desc "Generate Production database.yml"
  task :database_yml, :roles => [:web] do
    db_config = "#{shared_path}/config/database.yml.production"
    run "cp #{db_config} #{release_path}/config/database.yml"
  end

end

# default_environment["PATH"] = "/usr/bin:/bin:/usr/local/bin"