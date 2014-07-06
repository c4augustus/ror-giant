module JobsHelper
  require 'rest_client'

  def self.acquire_external_service_auth_code
    p "# Integrating with Jobs external service..."
    auth_code = nil
    RestClient.log = 'stdout'
    RestClient.get(
      "#{uri_base_auth}/authorize?client_id=#{auth_client_id}&response_type=code&action=Login&username=#{auth_username}&password=#{auth_password}&state=#{auth_state}"
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
      case response.code
      when 302 # Found
        uri_redirection = URI(response.headers[:location])
        #p "## Redirection URI <#{uri_redirection}>"
        uri_redirection_params = CGI::parse(uri_redirection.query)
        #p "## ...params <#{uri_redirection_params}>"
        auth_code = uri_redirection_params["code"] || auth_code
        #p "## ...code <#{auth_code}>"
      else
        # do not letting RestClient handle it
        ##response.return!(request, result, &block)
        p "### FAILED: response code #{response.code}, require 302/Found redirection that include the authorization code"
      end
=begin
      puts "response.code=#{response.code}"
      puts "response.cookies=#{response.cookies}"
      puts "response.headers=#{response.headers}"
      puts "response=#{response}"
=end
    }
    if auth_code
      p "...obtained authorization code <#{auth_code}>"
    else
      p "...did NOT obtain authorization code" 
    end
    auth_code
  end
end
