# Puma Web Server. Versions 5.0 and up are supported.
# Configuration is managed via ENV vars or the Puma DSL.
# Reference: https://puma.io/puma/Puma/DSL.html
#
# Thread and Worker Tuning:
# - Max threads should align with your Database Pool size.
# - WEB_CONCURRENCY (workers) is recommended for multi-core production environments.

# Thread pool configuration (Standard Rails default is 3-5)
threads_count = ENV.fetch("RAILS_MAX_THREADS") { 3 }
threads threads_count, threads_count

# Networking details (Default port is 3000)
port ENV.fetch("PORT") { 3000 }

# Deployment and Process Management
# Allow puma to be restarted by `bin/rails restart` command
plugin :tmp_restart

# Run Solid Queue supervisor inside Puma for single-server deployments
plugin :solid_queue if ENV["SOLID_QUEUE_IN_PUMA"]

# Specify the PID file for process tracking
pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }
