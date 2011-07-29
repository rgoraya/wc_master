require 'bundler/capistrano'
set :application, "wikicausality"


set :repository,  "git://github.com/rgoraya/wc_master.git"
set :scm, :git
set :git_enable_submodules, 1
set :branch, 'master'
set :ssh_options, {:forward_agent => true}

set :user, 'deploy'
set :use_sudo, false
set :stage, :production
set :runner, 'deploy'
set :deploy_to, "/u/apps/#{stage}/#{application}"
set :deploy_via, :remote_cache

set :app_server, :passenger

set :domain, "173.230.144.147"

#set :server_name, "captprice.com"
#set :server_alias, "*.captprice.com"
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, domain                          # Your HTTP server, Apache/etc
role :app, domain                          # This may be the same as your `Web` server
role :db,  domain, :primary => true # This is where Rails migrations will run

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

#after "deploy:setup", "deploy:nginx:setup"
after "deploy", "deploy:bundle_gems"
after "deploy:bundle_gems", "deploy:restart"

# If you are using Passenger mod_rails uncomment this:
 namespace :deploy do
	task :bundle_gems do
		run "cd #{deploy_to}/current && /opt/ruby-enterprise/bin/bundle install vendor/gems"
	end
   task :start do ; end
   task :stop do ; end
   task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
   end
 end
