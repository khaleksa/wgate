namespace :setup do

  desc "Upload database.yml file."
  task :upload_yml do
    on roles(:app) do
      execute "mkdir -p #{shared_path}/config"
      upload! StringIO.new(File.read("config/database.yml")), "#{shared_path}/config/database.yml"
    end
  end

  desc "Seed the database."
  task :seed_db do
    on roles(:app) do
      within "#{current_path}" do
        with rails_env: :production do
          execute :rake, "db:seed"
        end
      end
    end
  end

  desc "Symlinks config files for Nginx and Unicorn."
  task :symlink_config do
    on roles(:app) do
      upload!('shared/unicorn.paysys', "#{shared_path}/unicorn.paysys")
      sudo "sudo rm -f /etc/init.d/unicorn.paysys"
      sudo "ln -s #{shared_path}/unicorn.paysys /etc/init.d/unicorn.paysys"
      sudo "chmod +x /etc/init.d/unicorn.paysys"

      upload!('shared/paysys.conf', "#{shared_path}/paysys.conf")
      sudo 'sudo /etc/init.d/nginx stop'
      sudo "sudo rm -f /etc/nginx/sites-enabled/paysys.conf"
      sudo "ln -s #{shared_path}/paysys.conf /etc/nginx/sites-enabled/paysys.conf"
      sudo 'sudo /etc/init.d/nginx start'
    end
  end

end
