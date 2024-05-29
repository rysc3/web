class StatusController < ApplicationController
  require 'net/ssh'

  def index
    host = '129.24.245.8'
    username = 'ryan'
    private_key = 'app/assets/server_key'

    begin
      Net::SSH.start(host, username, keys: [private_key]) do |ssh|
        # Get hostname
        result_hostname = ssh.exec!("hostname")
        @hostname = result_hostname&.strip  # Use &. to safely call strip on result if it's not nil

        # Get system time
        result_time = ssh.exec!("date")
        @system_time = result_time&.strip
      end
    rescue Net::SSH::AuthenticationFailed
      flash[:error] = "Authentication failed. Please check your credentials."
      @hostname = nil
      @system_time = nil
    rescue StandardError => e
      flash[:error] = "Failed to fetch hostname or system time: #{e.message}"
      @hostname = nil
      @system_time = nil
    end
  end

  def data
    host = '129.24.245.8'
    username = 'ryan'
    private_key = 'app/assets/server_key'

    begin
      Net::SSH.start(host, username, keys: [private_key]) do |ssh|
        hostname_result = ssh.exec!("hostname")
        system_time_result = ssh.exec!("date") # Get system time from SSH server

        # Fetch node information using `scontrol show node` command
        nodes_result = ssh.exec!("scontrol show node")

        # Process node information to extract node IDs
        nodes = nodes_result.scan(/NodeName=(\S+)/).flatten

        # Prepare data to be sent as JSON
        data = {
          hostname: hostname_result&.strip,
          system_time: system_time_result&.strip,
          nodes: nodes
        }

        render json: data
      end
    rescue Net::SSH::AuthenticationFailed
      render json: { error: "Authentication failed. Please check your credentials." }, status: :unauthorized
    rescue StandardError => e
      render json: { error: "Failed to fetch data: #{e.message}" }, status: :internal_server_error
    end
  end

  private

  def process_output(output)
    # Process the output and extract the desired data
    # For example, parse the output as JSON or extract specific values
    # Return the processed data
  end
end
