require 'mongrel_cluster/recipes'

set :application, "k1tracking.ublip.com"
set :repository,  "https://ublip.svn.ey01.engineyard.com/Ublip_v2/branches/k1tracking"
set :scm_username,  "deploy"
set :scm_password,  "wucr5ch8v0"
set :user,        "ublip"
set :password,    "Was9A6ay"
set :deploy_to,     "/opt/ublip/rails"
set :rails_env, "production"
set :svn, "/usr/bin/svn"
set :sudo, "/usr/bin/sudo"
after "deploy:update_code", "symlink_configs"

ssh_options[:paranoid] = false

role :web, application
role :app, application
role :db, application, :primary => true
role :db, application

namespace :deploy do
  task :restart, :roles => :app do
    run "cd /opt/ublip/rails/current; mongrel_rails cluster::restart;"
  end
end


set :mongrel_conf, "#{current_path}/config/mongrel_cluster.yml"

task :symlink_configs, :roles => :app, :except => {:no_symlink => true} do
   run <<-CMD
     cd #{release_path} &&
     ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml &&
     ln -nfs #{shared_path}/config/mongrel_cluster.yml #{release_path}/config/mongrel_cluster.yml
   CMD
 end