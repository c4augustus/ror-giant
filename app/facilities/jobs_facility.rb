class JobsFacility
  require 'json'
  require 'rest_client'
  require 'uri'

  def log_integrating
    puts "# Integrating with jobs external service..."
    RestClient.log = 'stdout'
  end

  def acquire_external_auth_code
    sec = Rails.application.secrets[:service_external_jobs]
    return unless sec
    @external_auth_code = nil
    log_integrating
    RestClient.get(
      "#{sec['uri_base_auth']}/authorize"\
      "?client_id=#{sec['auth_client_id']}"\
      "&response_type=code&action=Login"\
      "&username=#{sec['auth_username']}"\
      "&password=#{sec['auth_password']}"\
      "&state=#{sec['auth_state']}"
=begin # @@@ WHY DOESN'T THIS WORK?
      "#{uri_base_auth}/authorize",
      params: {
        client_id:      auth_client_id,
        response_type:  'code',
        # OPTIONAL #redirect_uri: '',
        action:         'Login',
        username:       auth_username,
        pasword:        auth_password,
        state:          auth_state
      }
=end
    ) {|response, request, result, &block|
      if response.code == 302 # Found
        uri_redirection = URI(response.headers[:location])
        puts "#..response redirection URI <#{uri_redirection}>"
        uri_redirection_params = CGI::parse(uri_redirection.query)
        puts "#....params <#{uri_redirection_params}>"
        if param_code = uri_redirection_params["code"]
          @external_auth_code = param_code[0] || @external_auth_code
        end
        puts "#....code <#{@external_auth_code}>"
      else
        # do not letting RestClient handle it
        ##response.return!(request, result, &block)
        puts "### FAILED: response code #{response.code}, expected 302/Found redirection that include the authorization code"
      end
=begin
      puts "response.code=#{response.code}"
      puts "response.cookies=#{response.cookies}"
      puts "response.headers=#{response.headers}"
      puts "response=#{response}"
=end
    }
    if @external_auth_code
      puts "#..obtained authorization code <#{@external_auth_code}>"
    else
      puts "#..did NOT obtain authorization code" 
    end
    @external_auth_code
  end

  def external_auth_code
    @external_auth_code ||= acquire_external_auth_code
  end

  def acquire_external_access_token
    sec = Rails.application.secrets[:service_external_jobs]
    return unless sec && external_auth_code
    @external_access_token = nil
    log_integrating
    RestClient.post(
      "#{sec['uri_base_auth']}/token"\
      "?grant_type=authorization_code"\
      "&code=#{external_auth_code}"\
      "&client_id=#{sec['auth_client_id']}"\
      "&client_secret=#{sec['auth_client_secret']}",
      nothing: 'nothing'
    ) {|response, request, result, &block|
      if response.code == 200 # Success
        puts "# SUCCESS, response=#{response}"
        responseHash = JSON.parse response
        @external_access_token = responseHash["access_token"]
        @external_refresh_token = responseHash["refresh_token"]
      else
        # do not letting RestClient handle it
        ##response.return!(request, result, &block)
        puts "### FAILED: response code #{response.code}"
      end
    }
    if @external_access_token
      puts "#..obtained external access token <#{@external_access_token}>"
    else
      puts "#..did NOT obtain external access token" 
    end
    if @external_refresh_token
      puts "#..obtained external refresh token <#{@external_refresh_token}>"
    else
      puts "#..did NOT obtain external refresh token" 
    end
    @external_access_token
  end

  def external_access_token
    @external_access_token ||= acquire_external_access_token
  end

  def acquire_external_session_key
    sec = Rails.application.secrets[:service_external_jobs]
    return unless sec && external_access_token
    @external_session_key = nil
    log_integrating
    RestClient.get(
      URI.encode("#{sec['uri_base_rest']}/login"\
                 "?version=*"\
                 "&access_token=#{external_access_token}")
    ) {|response, request, result, &block|
      if response.code == 200 # Success
        puts "# SUCCESS, response=#{response}"
        responseHash = JSON.parse response
        @external_session_key = responseHash["BhRestToken"]
        @external_url_rest = responseHash["restUrl"]
      else
        # do not letting RestClient handle it
        ##response.return!(request, result, &block)
        puts "### FAILED: response code #{response.code}"
      end
    }
    if @external_session_key
      puts "#..obtained external session key <#{@external_session_key}>"
    else
      puts "#..did NOT obtain external session key" 
    end
    if @external_url_rest
      puts "#..obtained external URL for REST <#{@external_url_rest}>"
    else
      puts "#..did NOT obtain external URL for REST" 
    end
    @external_session_key
  end

  def external_session_key
    @external_session_key ||= acquire_external_session_key
  end

  def refresh_jobs
    if external_session_key
    end
    Job.all 
  end
end
