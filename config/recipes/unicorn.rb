namespace :unicorn do

  %w[start stop restart reload].each do |command|
    desc "Run Unicorn #{command} script"
    task command do
      on roles(:all) do
        sudo "service unicorn.paysys #{command}"
      end
    end
  end

end
