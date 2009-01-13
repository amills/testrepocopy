set(:customer_name) do
  "amj"
end

set(:rails_env) do
  "slicehost"
end

set(:monited) do
  "n"
end

set :keep_releases, 5
set :application,   'ublip'
set :scm_username,  'rsinek'
set :scm_password,  'ch5tryng'
set :user,          'ublip'
#set :password,      's7aPRA7r'
set :deploy_to, DeployManagerClient.get_app_directory(customer_name)
set :deploy_via,    :export
set :monit_group,   'mongrel'
set :scm,           :subversion
set :runner, 'ublip'

# comment out if it gives you trouble. newest net/ssh needs this set.
ssh_options[:paranoid] = false

# default_run_options[:pty] = true # required for svn+ssh://

# =============================================================================
# ROLES
# =============================================================================
# You can define any number of roles, each of which contains any number of
# machines. Roles might include such things as :web, or :app, or :db, defining
# what the purpose of each machine is. You can also specify options that can
# be used to single out a specific subset of boxes in a particular role, like
# :primary => true.
set :deploy_to, DeployManagerClient.get_app_directory(customer_name)
set :db_admin, DeployManagerClient.get_db_admin(customer_name)

task :production do
  role :db, DeployManagerClient.get_app_servers(customer_name)[0], :primary => true
  app_servers = DeployManagerClient.get_app_servers(customer_name)
  app_servers.each_index do |index|
    if index=0
      role :app, app_servers[index]
    else
      role :app, app_servers[index], :no_release => true, :no_symlink => true, :no_daemons => true
    end
  end
  set :repository, "#{DeployManagerClient.get_repo(customer_name)}/tags/current_production_build"
end

task :staging do
  role :db, DeployManagerClient.get_staging_app_server(customer_name), :primary => true
  role :app, DeployManagerClient.get_staging_app_server(customer_name), :mongrel => true
  set :repository, "#{DeployManagerClient.get_repo(customer_name)}/trunk"
end

# =============================================================================
# Any custom after tasks can go here.
# after "deploy:symlink_configs", "ublip_custom"
# task :ublip_custom, :roles => :app, :except => {:no_release => true, :no_symlink => true} do
#   run <<-CMD
#   CMD
# end
# =============================================================================
# TASKS
# Don't change unless you know what you are doing!
after "deploy", "deploy:cleanup"
after "deploy:migrations", "deploy:cleanup"
after "deploy:update_code","deploy:symlink_configs"
# uncomment the following to have a database backup done before every migration
# before "deploy:migrate", "db:dump"
before "deploy", "daemons:stop"
after "deploy", "daemons:start"
after "deploy", "setup_db_procs"
after "deploy:migrate", "setup_db_procs"
after "deploy:migrations", "setup_db_procs"

# =============================================================================
namespace :mongrel do
  desc <<-DESC
 Start Mongrel processes on the app server.  This uses the :use_sudo variable to determine whether to use sudo or not. By default, :use_sudo is
 set to true.
 DESC
  task :start, :roles => :app do
    if monited.eql?("y")
      sudo "/usr/bin/monit start all -g #{monit_group}"
    else
      run "cd /opt/ublip/rails/current; mongrel_rails cluster::start;"
    end
  end
  
  desc <<-DESC
 Restart the Mongrel processes on the app server by starting and stopping the cluster. This uses the :use_sudo
 variable to determine whether to use sudo or not. By default, :use_sudo is set to true.
 DESC
  task :restart, :roles => :app do
    if monited.eql?("y")
      sudo "/usr/bin/monit restart all -g #{monit_group}"
    else
      run "cd /opt/ublip/rails/current; mongrel_rails cluster::restart;"
    end
  end
  
  desc <<-DESC
 Stop the Mongrel processes on the app server.  This uses the :use_sudo
 variable to determine whether to use sudo or not. By default, :use_sudo is
 set to true.
 DESC
  task :stop, :roles => :app do
    if monited.eql("y")
      sudo "/usr/bin/monit stop all -g #{monit_group}"
    else
      run "cd /opt/ublip/rails/current; mongrel_rails cluster::stop;"
    end
  end
  
  desc "Get the status of your mongrels"
  task :status, :roles => :app do
    @monit_output ||= { }
    sudo "/usr/bin/monit status" do |channel, stream, data|
      @monit_output[channel[:server].to_s] ||= [ ]
      @monit_output[channel[:server].to_s].push(data.chomp)
    end
    @monit_output.each do |k,v|
      puts "#{k} -> #{'*'*55}"
      puts v.join("\n")
    end
  end
end

# =============================================================================
namespace :nginx do
  desc "Start Nginx on the app server."
  task :start, :roles => :app do
    sudo "/etc/init.d/nginx start"
  end
  
  desc "Restart the Nginx processes on the app server by starting and stopping the cluster."
  task :restart , :roles => :app do
    sudo "/etc/init.d/nginx restart"
  end
  
  desc "Stop the Nginx processes on the app server."
  task :stop , :roles => :app do
    sudo "/etc/init.d/nginx stop"
  end
  
  desc "Tail the nginx logs for this environment"
  task :tail, :roles => :app do
    run "tail -f /var/log/engineyard/nginx/vhost.access.log" do |channel, stream, data|
      puts "#{channel[:server]}: #{data}" unless data =~ /^10\.[01]\.0/ # skips lb pull pages
      break if stream == :err
    end
  end
end

# =============================================================================
# after "deploy:update_code","ferret:symlink_configs" # uncomment this to hook up configs by default
# after "deploy:symlink","ferret:restart"             # uncomment this to restart ferret drb after deploy
namespace :ferret do
  desc "After update_code you want to symlink the index and ferret_server.yml file into place"
  task :symlink_configs, :roles => :app, :except => {:no_release => true} do
    run <<-CMD
     cd #{  th} &&
     ln -nfs #{shared_path}/config/ferret_server.yml #{release_path}/config/ferret_server.yml &&
     ln -nfs #{shared_path}/index #{release_path}/index
   CMD
  end
  [:start,:stop,:restart].each do |op|
    task op, :roles => :app, :except => {:no_release => true} do
      sudo "/usr/bin/monit #{op} all -g ferret_#{application}"
    end
  end
end

# =============================================================================
namespace(:deploy) do
  task :symlink_configs, :roles => :app, :except => {:no_symlink => true} do
    run <<-CMD
     cd #{release_path} &&
     ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml &&
     ln -nfs #{shared_path}/config/mongrel_cluster.yml #{release_path}/config/mongrel_cluster.yml &&
     ln -nfs #{shared_path}/config/enfora_gateway.yml #{release_path}/config/enfora_gateway.yml &&
     ln -nfs #{shared_path}/config/environments/production.rb #{release_path}/config/production.rb
   CMD
  end
  
  desc "Long deploy will throw up the maintenance.html page and run migrations
       then it restarts and enables the site again."
  task :long do
    transaction do
      update_code
      web.disable
      symlink
      migrate
    end
    
    restart
    web.enable
  end
  
  desc "Restart the Mongrel processes on the app server by calling restart_mongrel_cluster."
  task :restart, :roles => :app do
    mongrel.restart
  end
  
  desc "Start the Mongrel processes on the app server by calling start_mongrel_cluster."
  task :spinner, :roles => :app do
    mongrel.start
  end
  
  desc "Tail the Rails production log for this environment"
  task :tail_production_logs, :roles => :app do
    run "tail -f #{shared_path}/log/production.log" do |channel, stream, data|
      puts  # for an extra line break before the host name
      puts "#{channel[:server]} -> #{data}"
      break if stream == :err
    end
  end
end

namespace :daemons do
  desc "Start all daemons"
  task :start, :roles => :app, :except => {:no_daemons => true} do
    run "#{current_path}/script/daemons start"
  end
  
  desc "Stop all daemons"
  task :stop, :roles => :app, :except => {:no_daemons => true} do
    if FileTest.exist?("#{current_path}/script/daemons")
      run "#{current_path}/script/daemons stop"
    end
  end
end