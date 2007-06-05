require 'mongrel_cluster/recipes'


set :svnstring, "Ublip"
set :application, "dev2.ublip.com"


set :repository, "svn+ssh://svn.ublip.com/home/svn/repos/#{svnstring}/trunk"
set :user, "cappy"
set :svn, "/opt/csw/bin/svn"
set :sudo, "/opt/csw/bin/sudo"
ssh_options[:paranoid] = false

role :web, application
role :app, application
role :db, application, :primary => true
role :db, application

set :deploy_to, "/opt/www/apps/#{application}" 

set :mongrel_conf, "#{current_path}/config/mongrel_cluster.yml"
