namespace :nginx do

  %w[start stop restart reload].each do |command|
    desc "Run Nginx #{command} script"
    task command do
      on roles(:all) do
        sudo "service nginx #{command}"
      end
    end
  end

end
