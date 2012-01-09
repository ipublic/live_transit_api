set :application, "live_transit_api"
set :repository,  "."
set :deploy_to, "/var/www/html/live_transit_api"

set :scm, :none
# set :use_sudo, false
set :user, :realtimewebsvcs
set :keep_releases, 2
set :deploy_via, :copy
set :copy_exclude, [".git/*", "Gemfile.lock", "config/couchdb.yml"]

set :db_connection_settings_file, File.join(File.dirname(__FILE__), "couchdb.yml")

default_run_options[:shell] = false

role :web, "172.30.12.210"
role :app, "172.30.12.210"
role :db, "172.30.12.210", :primary => true

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
     put(File.read(db_connection_settings_file), "#{File.join(current_path, 'config', 'couchdb.yml')}", :via => :scp)
     run "rvm rvmrc trust #{File.join(current_release)}"
#     run "cd #{current_release}; RAILS_ENV=production bundle install"
#     run "cd #{current_release}; RAILS_ENV=production bundle exec rake assets:precompile"
     run "chown realtimewebsvcs:rvm #{File.join(current_path,'..','..')} -R"
     run "touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end
