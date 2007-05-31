require 'mongrel_cluster/recipes'

set :application, "ublip"
set :repository, "file:////svn.ublip.com/home/svn/repos/#{application}/trunk"
set :user, "cappy"

role :web, "dev1.ublip.com", "dev2.ublip.com", "dev3.ublip.com"
role :app, "dev1.ublip.com", "dev2.ublip.com", "dev3.ublip.com"

set :deploy_to, "/opt/www/dev/#{application}" 

set :mongrel_conf, "#{current_path}/config/mongrel_cluster.yml"
