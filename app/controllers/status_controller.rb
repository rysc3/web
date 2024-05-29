class StatusController < ApplicationController
  require 'net/ssh'

  def index
    host = '129.24.245.8'
    username = 'ryan'
    private_key = 'app/assets/server_key'

    begin
      Net::SSH.start(host, username, keys: [private_key]) do |ssh|
        result = ssh.exec!("hostname")
        @hostname = result&.strip  # Use &. to safely call strip on result if it's not nil
      end
    rescue Net::SSH::AuthenticationFailed
      flash[:error] = "Authentication failed. Please check your credentials."
      @hostname = nil
    rescue StandardError => e
      flash[:error] = "Failed to fetch hostname: #{e.message}"
      @hostname = nil
    end
  end

  private

  def process_output(output)
    # Process the output and extract the desired data
    # For example, parse the output as JSON or extract specific values
    # Return the processed data
  end
end
