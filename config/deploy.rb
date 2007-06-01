require 'mongrel_cluster/recipes'


set :application, "Ublip"
#set :repository, "file:///home/svn/repos/#{application}/trunk"
set :repository, "svn+ssh://svn.ublip.com/home/svn/repos/#{application}/trunk"
set :user, "cappy"
set :svn, "/opt/csw/bin/svn"
set :sudo, "/opt/csw/bin/sudo"
ssh_options[:paranoid] = false

role :web, "dev2.ublip.com"
role :app, "dev2.ublip.com"
role :db, "dev2.ublip.com", :primary => true

set :deploy_to, "/opt/www/dev/#{application}" 

set :mongrel_conf, "#{current_path}/config/mongrel_cluster.yml"
