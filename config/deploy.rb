# config valid for current version and patch releases of Capistrano
lock "~> 3.18.1"

set :application, "weather"
set :repo_url, "git@github.com:dsadaka/weather.git"

# Default branch is :master
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp
set :deploy_via,      :remote_cache
set :format, :pretty
set :log_level, :debug
set :rvm_ruby_version, '3.1.4@weather --create'      # Defaults to: 'default'
set :bundle_binstubs, nil
set :rvm_type, :system

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
append :linked_files, 'config/master.key', '.env', "config/database.yml", 'storage/production.sqlite3'

# Default value for linked_dirs is []
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure
set :use_sudo,        false
set :puma_bind,   ->   {"unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"}
set :puma_state,  ->   {"#{shared_path}/tmp/pids/puma.state"}
set :puma_pid,    ->   {"#{shared_path}/tmp/pids/puma.pid"}
set :puma_access_log, -> {"#{shared_path}/log/puma.error.log"}
set :puma_error_log,  -> {"#{shared_path}/log/puma.access.log"}
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true  # Change to true if using ActiveRecord
set :puma_workers,  2
set :puma_threads, [5, 16]
set :puma_enable_socket_service, true

set :nginx_config_name, "#{fetch(:application)}_#{fetch(:stage)}"
set :nginx_server_name, -> {"localhost #{fetch(:server_name)}"}
set :nginx_listen, 80
set :nginx_roles, :app