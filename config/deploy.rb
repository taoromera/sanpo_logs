require 'bundler/capistrano'

set :application, "Sanpo"
logger.level = Logger::IMPORTANT

set :scm, :git
set :repository,  "git@github.com:JordiPolo/sanpo.git"
set :git_shallow_clone, 1
set :branch, "master"

set :user, "sanpo"
set :use_sudo, false

set :keep_releases, 3
set :deploy_to, "/home/sanpo/rails-interface/deploy"

set :location, "180.235.230.73"
# ssh_options[:keys] = ["~/.sanpo/sanpoDB.pem"]

role :app, location
role :web, location
role :db, location, :primary => true

set :rails_env, 'production'
#this avoid capistrano touching all assets (we dont have them)
set :normalize_asset_timestamps, false

namespace :deploy do
  desc "Restart Application"
  task :restart, :roles => :app do
    put File.read("config/initializers/01_keys.rb"), "#{deploy_to}/current/config/initializers/01_keys.rb", :mode => 0664
    run "kill `ps ax | grep thin | grep -v grep | cut -f 2`; true "
    run "cd #{deploy_to}/current/ &&  bundle exec thin start -e production -d"
  end

end

#dont forget to delete old stuff
after "deploy:restart", "deploy:cleanup"

#used for debugging
desc "Echo environment vars"
namespace :env do
  task :echo do
    run "echo printing out cap info on remote server"
    run "echo $PATH"
    run "printenv"
  end
end


#bautiful stuff, can be deleted without change of behaviour
@spinner_running = false
@chars = ['|', '/', '-', '\\']
@spinner = Thread.new do
  loop do
    unless @spinner_running
      Thread.stop
    end
    print @chars[0]
    sleep(0.1)
    print "\b"
    @chars.push @chars.shift
  end
end

def start_spinner
  @spinner_running = true
  @spinner.wakeup
end
def stop_spinner
  @spinner_running = false
  print "\b"
end


STDOUT.sync
before "deploy:update_code" do
      print "Updating Code........"
      start_spinner()
end
after "deploy:update_code" do
      stop_spinner()
      puts "Done."
end

before "deploy:restart" do
      print "Restarting Sanpo........"
      start_spinner()
end
after "deploy:restart" do
      stop_spinner()
      puts "Done."
end

