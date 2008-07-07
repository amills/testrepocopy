# Please install the Engine Yard Capistrano gem
# gem install eycap --source http://gems.engineyard.com

require "eycap/recipes"

# =============================================================================
# ENGINE YARD REQUIRED VARIABLES
# =============================================================================
# You must always specify the application and repository for every recipe. The
# repository must be the URL of the repository you want this recipe to
# correspond to. The :deploy_to variable must be the root of the application.

set :keep_releases,       5
set :application,         "ublip_newstage"
set :repository,          "https://ublip.svn.ey01.engineyard.com/Ublip_v2/trunk"
set :scm_username,       "deploy"
set :scm_password,       "wucr5ch8v0"
set :user,                "ublip"
set :password,            "pr1c7lic6"
set :deploy_to,           "/data/#{application}"
set :deploy_via,          :filtered_remote_cache
set :repository_cache,    "/var/cache/engineyard/#{application}"
set :monit_group,         "ublip_newstage"
set :scm,                 :subversion

set :staging_database, "ublip_prod"
set :staging_dbhost,   "mysql50-5"








set :dbuser,        "ublip_db"
set :dbpass,        "pr1c7lic6"

# comment out if it gives you trouble. newest net/ssh needs this set.
ssh_options[:paranoid] = false


# =============================================================================
# ROLES
# =============================================================================
# You can define any number of roles, each of which contains any number of
# machines. Roles might include such things as :web, or :app, or :db, defining
# what the purpose of each machine is. You can also specify options that can
# be used to single out a specific subset of boxes in a particular role, like
# :primary => true.

  
  
  
  
task :staging do
  
  role :web, "65.74.139.2:8514" # ublip_newstage [mongrel] [mysql50-5]
  role :app, "65.74.139.2:8514", :mongrel => true
  role :db , "65.74.139.2:8514", :primary => true
  
  
  set :rails_env, "staging"
  set :environment_database, defer { staging_database }
  set :environment_dbhost, defer { staging_dbhost }
end

  
  
  
  
  
  
  
  
  
  
  
  
  
  


# =============================================================================
# Any custom after tasks can go here.
# after "deploy:symlink_configs", "ublip_newstage_custom"
# task :ublip_newstage_custom, :roles => :app, :except => {:no_release => true, :no_symlink => true} do
#   run <<-CMD
#   CMD
# end
# =============================================================================

# Do not change below unless you know what you are doing!

after "deploy", "deploy:cleanup"
after "deploy:migrations" , "deploy:cleanup"
after "deploy:update_code", "deploy:symlink_configs"

# uncomment the following to have a database backup done before every migration
# before "deploy:migrate", "db:dump"


