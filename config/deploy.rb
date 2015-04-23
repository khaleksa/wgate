# config valid only for Capistrano 3.1
lock '3.1.0'

load 'config/recipes/nginx.rb'
load 'config/recipes/unicorn.rb'

application = 'paysys'

set :application, application
set :repo_url, 'git@bitbucket.org:khaleksa/paysys.git'


set :rvm_type, :system
set :rvm_user, 'Alexandra'
set :rvm_ruby_version, '2.1.1'
set :deploy_to, '/var/www/paysys'

namespace :deploy do

  task :seed do
    on roles(:all) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, "db:seed"
        end
      end
    end
  end

  desc 'Setup'
  task :setup do
    on roles(:all) do
      execute "mkdir #{shared_path}/config/"
      execute "mkdir /var/www/#{application}/run/"
      execute "mkdir /var/www/#{application}/log/"
      execute "mkdir #{shared_path}/system"

      upload!('shared/database.yml', "#{shared_path}/config/database.yml")

      upload!('shared/unicorn.paysys', "#{shared_path}/unicorn.paysys")
      sudo "ln -s #{shared_path}/unicorn.paysys /etc/init.d/unicorn.paysys"
      sudo "chmod +x /etc/init.d/unicorn.paysys"

      upload!('shared/paysys.conf', "#{shared_path}/paysys.conf")
      sudo 'sudo /etc/init.d/nginx stop'
      # sudo "sudo rm -f /etc/nginx/nginx.conf"
      sudo "ln -s #{shared_path}/paysys.conf /etc/nginx/sites-enabled/paysys.conf"
      sudo 'sudo /etc/init.d/nginx start'

      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, "db:create"
          execute :rake, "db:migrate"
        end
      end

    end
  end

  desc 'Create symlink'
  task :symlink do
    on roles(:all) do
      execute "ln -s #{shared_path}/system #{release_path}/public/system"
      execute "ln -s #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    end
  end

  after :finishing, 'deploy:cleanup'
  after :finishing, 'deploy:restart'

  after :updating, 'deploy:symlink'

  before :setup, 'deploy:starting'
  before :setup, 'deploy:updating'
  before :setup, 'bundler:install'

end
