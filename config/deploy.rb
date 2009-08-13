set :application, "datagov"
set :repository,  "ssh://nfs.greenriver.org/git/datagov.git"

set :deploy_to, "/var/www/#{application}-production"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
set :scm, :git
set :keep_releases, 10

role :app, "ruby2.greenriver.org"
role :web, "ruby2.greenriver.org"
role :db,  "ruby2.greenriver.org", :primary => true

namespace :deploy do
  [:start, :stop].each do |name| 
    desc "#{name} the application (does nothing w/ passenger)" 
    task name do 
    end 
  end 

  desc "Restart the Application" 
  task :restart do 
    run "touch #{current_path}/tmp/restart.txt" 
  end 

  task :link_conf do
    run "ln -fs #{shared_path}/config/* #{current_release}/config"
  end

  task :link_public do
    run "ln -nfs #{shared_path}/public/* #{current_release}/public"
  end

  desc "Set the environment.rb owner since this is the user the process uses"
  task :chown_environment, :roles => :app do
    sudo "chown _#{application} #{current_release}/config/environment.rb"
    sudo "chown _#{application} #{current_release}/public/javascripts"
  end
end

after 'deploy:update_code', 'deploy:link_conf', 'deploy:link_public'
after 'deploy:update', 'deploy:chown_environment', 'deploy:restart'

## Rake helper task.
def run_remote_rake(rake_cmd)
  run "cd #{current_path} && rake RAILS_ENV=#{rails_env} #{rake_cmd.split(',').join(' ')}"
end
