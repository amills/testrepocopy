require 'mongrel_cluster/recipes'

set :application, "Ublip"
set :repository, "file:///home/svn/repos/#{application}/trunk"
set :user, "cappy"
set :svn, "/opt/csw/bin/svn"

role :web, "dev1.ublip.com", "dev2.ublip.com", "dev3.ublip.com"
role :app, "dev1.ublip.com", "dev2.ublip.com", "dev3.ublip.com"
role :db, "dev1.ublip.com", "dev2.ublip.com", "dev3.ublip.com", :primary => true

set :deploy_to, "/opt/www/dev/#{application}" 

set :mongrel_conf, "#{current_path}/config/mongrel_cluster.yml"
