require 'mongrel_cluster/recipes'

set :application, "rapid.ublip.com"
set :repository,  "https://ublip.svn.ey01.engineyard.com/Ublip_rapid/trunk"
set :scm_username,  "deploy"
set :scm_password,  "wucr5ch8v0"
set :user,        "admin"
set :password,    "SkecunWiTwav7oci"
set :deploy_to,     "/opt/ublip/rapid"
set :rails_env, "production"
set :svn, "/opt/csw/bin/svn"
set :sudo, "/opt/csw/bin/sudo"
after "deploy:update_code", "symlink_configs"

ssh_options[:paranoid] = false

role :web, application
role :app, application
role :db, application, :primary => true
role :db, application

set :mongrel_conf, "#{current_path}/config/mongrel_cluster.yml"

task :symlink_configs, :roles => :app, :except => {:no_symlink => true} do
   run <<-CMD
     cd #{release_path} &&
     ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml &&
     ln -nfs #{shared_path}/config/mongrel_cluster.yml #{release_path}/config/mongrel_cluster.yml
   CMD
 end