set :application, "macrodeck"
set :repository,  "http://svn.macrodeck.com/macrodeck/trunk"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:

set :deploy_to, "/home/railsapps/macrodeck"

# Gateway is prometheus.poseidonimaging.com since the servers are on localhost... workaround for
# no TCP/IP on database
# gateway may no longer be required # set :gateway, "railsapps@prometheus.poseidonimaging.com"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

role :app, "railsapps@prometheus.poseidonimaging.com"
role :web, "railsapps@prometheus.poseidonimaging.com"
role :db,  "railsapps@prometheus.poseidonimaging.com", :primary => true

before :deploy, "deploy:stop_ultrasphinx"

# Restart functions
desc "Restarts Apache"
deploy.task :restart_web_server, :roles => :web do
	sudo "/etc/init.d/apache2 restart"
end

desc "Restarts Mongrel"
deploy.task :restart, :roles => :web do
	sudo "/etc/init.d/mongrel.macrodeck restart"
	reindex
	start_ultrasphinx
end
        
desc "Reindexes search engine"
deploy.task :reindex, :roles => :web do
	run "/home/railsapps/macrodeck-reindex.sh"
end

desc "Stops search engine"
deploy.task :stop_ultrasphinx, :roles => :web do
	sudo "/etc/init.d/ultrasphinx.macrodeck stop"
end

desc "Starts search engine"
deploy.task :start_ultrasphinx, :roles => :web do
	sudo "/etc/init.d/ultrasphinx.macrodeck start"
end

desc "Restarts search engine"
deploy.task :restart_ultrasphinx, :roles => :web do
	sudo "/etc/init.d/ultrasphinx.macrodeck restart"
end
