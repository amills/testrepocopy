# =============================================================================
# ENGINE YARD REQUIRED VARIABLES
# =============================================================================
# You must always specify the application and repository for every recipe. The
# repository must be the URL of the repository you want this recipe to
# correspond to. The deploy_to path must be the path on each machine that will
# form the root of the application path.

set :keep_releases, 5
set :application,   'ublip'
set :repository,    'https://ublip.svn.ey01.engineyard.com/Ublip_v2/trunk'
set :scm_username,  'deploy'
set :scm_password,  'wucr5ch8v0'
set :user,          'ublip'
set :password,      'mop3j6x4'
set :deploy_to,     "/data/#{application}"
set :deploy_via,    :export
set :monit_group,   'mongrel'
set :scm,           :subversion

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
task :production do
  role :web, '65.74.139.2:8049'
  role :app, '65.74.139.2:8049'
  role :db, '65.74.139.2:8049', :primary => true
  role :app, '65.74.139.2:8050', :no_release => true, :no_symlink => true 
end

task :staging do
    
end

# =============================================================================
# TASKS
# Don't change unless you know what you are doing!
after "deploy", "deploy:cleanup"
after "deploy:migrations", "deploy:cleanup"
after "deploy:update_code","deploy:symlink_configs"

namespace(:deploy) do  
  task :symlink_configs, :roles => :app, :except => {:no_symlink => true} do
    run <<-CMD
      cd #{release_path} &&
      ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml &&
      ln -nfs #{shared_path}/config/mongrel_cluster.yml #{release_path}/config/mongrel_cluster.yml
    CMD
  end
  
  desc "Long deploy will throw up the maintenance.html page and run migrations 
        then it restarts and enables the site again."
  task :long do
    transaction do
      update_code
      web.disable
      symlink
      migrations
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
  
  namespace :mongrel do
    desc <<-DESC
    Start Mongrel processes on the app server.  This uses the :use_sudo variable to determine whether to use sudo or not. By default, :use_sudo is
    set to true.
    DESC
    task :start, :roles => :app do
      sudo "/usr/bin/monit start all -g #{monit_group}"
    end

    desc <<-DESC
    Restart the Mongrel processes on the app server by starting and stopping the cluster. This uses the :use_sudo
    variable to determine whether to use sudo or not. By default, :use_sudo is set to true.
    DESC
    task :restart, :roles => :app do
      sudo "/usr/bin/monit restart all -g #{monit_group}"
    end

    desc <<-DESC
    Stop the Mongrel processes on the app server.  This uses the :use_sudo
    variable to determine whether to use sudo or not. By default, :use_sudo is
    set to true.
    DESC
    task :stop, :roles => :app do
      sudo "/usr/bin/monit stop all -g #{monit_group}"
    end
  end
  
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
        puts "#{channel[:host]}: #{data}" unless data =~ /^10\.0\.0/ # skips lb pull pages
        break if stream == :err    
      end
    end
  end

  desc "Tail the Rails production log for this environment"
  task :tail_production_logs, :roles => :app do
    run "tail -f #{shared_path}/log/production.log" do |channel, stream, data|
      puts  # for an extra line break before the host name
      puts "#{channel[:host]}: #{data}" 
      break if stream == :err    
    end
  end
end