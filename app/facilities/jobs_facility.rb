class JobsFacility

  FAKE_IT = false
  DUMP_JSON_CATEGORIES = false
  DUMP_JSON_JOBS = false
  INCLUDE_ALL_FIELDS_CATEGORIES = true
  INCLUDE_ALL_FIELDS_JOBS = false

  SECONDS_INTERVAL_REFRESH = 800

  def refresh_jobs(options={})
    unless @time_refresh_last &&
        (Time.now < (@time_refresh_last + SECONDS_INTERVAL_REFRESH))
      Job.delete_all
      @external_access_token = nil
      @external_session_key = nil
      #retrieve_all_categories
      retrieve_all_jobs
      @time_refresh_last = Time.now
    end
    category = Job.category_matching(options[:category])
    Job.where((category && (category != 'ALL')) ? {category: category} : {}).
      sort({id_scheme_ext:-1}) 
  end

private

  def retrieve_all_categories
    if (hashcategories = fetch_external_categories_hash(INCLUDE_ALL_FIELDS_CATEGORIES))
      puts "## categories JSON: #{hashcategories}"
    end
  end

  def retrieve_all_jobs
    if FAKE_IT
      retrieve_all_jobs_fake
    else
      retrieve_all_jobs_real
    end
  end

  def retrieve_all_jobs_fake
    job1 = Job.find_or_create_by(id_scheme_ext: 'FAKE0001')
    job1.write_attributes(
      category:    'CREATIVE',
      title:       'FAKE TITLE #1',
      description: 'FAKE DESCRIPTION #1')
    job1.save
    job2 = Job.find_or_create_by(id_scheme_ext: 'FAKE0002')
    job2.write_attributes(
      category:    'INTERACTIVE',
      title:       'FAKE TITLE #2',
      description: 'FAKE DESCRIPTION #2')
    job2.save
    job3 = Job.find_or_create_by(id_scheme_ext: 'FAKE0003')
    job3.write_attributes(
      category:    'MARKETING',
      title:       'FAKE TITLE #3',
      description: 'FAKE DESCRIPTION #3')
    job3.save
  end

  def retrieve_all_jobs_real
    offset = 0
    until 0 == (count = retrieve_jobs_starting_at(offset))
      offset += count
    end
  end

  def retrieve_jobs_starting_at(offset)
    count = 0
    if (hashjobs = fetch_external_jobs_hash(offset, INCLUDE_ALL_FIELDS_JOBS))
      hashjobs["data"].each do |hashjob|
        if (idschemeext = hashjob["id"])
          job = Job.find_or_create_by(id_scheme_ext: idschemeext)
          categoryparsed = hashjob["skillList"].try(:lines).try(:first).try(:chomp).try(:delete, ';')
          categorymatching = Job.category_matching(categoryparsed)
          job.write_attributes(
            category:         categorymatching,
            description:      hashjob["description"],
            employment_type:  hashjob["employmentType"],
            start_date:       hashjob["startDate"],
            title:            hashjob["title"])
## !!! disabled, so now these details must be provided in the description
=begin
            pay_rate:         hashjob["payRate"],
            salary:           hashjob["salary"],
            salary_unit:      hashjob["salaryUnit"],
=end
          job.save
          count += 1
        end 
      end
    end
    count
  end

  require 'json'
  require 'rest_client'
  require 'uri'

  def log_integrating
    puts "# Integrating with jobs external service..."
    RestClient.log = 'stdout'
  end

  def fetch_external_categories_hash(including_all_fields)
    if external_session_key && external_url_rest
      log_integrating
      RestClient.get(URI.encode(
        "#{external_url_rest}search/Category"\
        "?BhRestToken=#{external_session_key}"\
        "&fields=#{including_all_fields ? "*" :
          "id,name"}"\
        "&count=#{count}"\
        "&start=#{start}"
      )) {|response, request, result, &block|
        if response.code == 200 # Success
          #puts "# SUCCESS, response=#{response}"
          if DUMP_JSON_CATEGORIES
            if including_all_fields
              File.open("db/data_bh_categories_all_fields_"\
                        "#{DateTime.now.strftime("%Y%m%d%H%M%S")}.json", "w") do |f|
                f.write(response.encode)
              end
            else
              File.open("db/data_bh_categories_selected_fields_"\
                        "#{DateTime.now.strftime("%Y%m%d%H%M%S")}.json", "w") do |f|
                f.write(response.encode)
              end
            end
          end
          return JSON.parse response
        else
          # do not letting RestClient handle it
          ##response.return!(request, result, &block)
          puts "### FAILED: response code #{response.code}"
        end
      }
    end
    nil
  end

  def fetch_external_jobs_hash(offset, including_all_fields)
    if external_session_key && external_url_rest
      log_integrating
      RestClient.get(URI.encode(
        "#{external_url_rest}search/JobOrder"\
        "?BhRestToken=#{external_session_key}"\
        "&query=isOpen:1 AND isDeleted:0 AND NOT status:archive"\
        "&fields=#{including_all_fields ? "*" :
          ## !!! disabled, so now these details must be provided in the description
          ##"id,categories,title,employmentType,startDate,payRate,salary,salaryUnit,description"}"\
          ##"id,skillList,description"}"\
          "id,employmentType,description,skillList,startDate,title"}"\
        "&start=#{offset}"
      )) {|response, request, result, &block|
        if response.code == 200 # Success
          #puts "# SUCCESS, response=#{response}"
          if DUMP_JSON_JOBS
            if including_all_fields
              File.open("db/data_bh_job_offers_all_fields_"\
                        "#{DateTime.now.strftime("%Y%m%d%H%M%S")}.json", "w") do |f|
                f.write(response.encode)
              end
            else
              File.open("db/data_bh_job_offers_selected_fields_"\
                        "#{DateTime.now.strftime("%Y%m%d%H%M%S")}.json", "w") do |f|
                f.write(response.encode)
              end
            end
          end
          return JSON.parse response
        else
          # do not letting RestClient handle it
          ##response.return!(request, result, &block)
          puts "### FAILED: response code #{response.code}"
        end
      }
    end
    nil
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
    if @external_refresh_token
      RestClient.post(
        "#{sec['uri_base_auth']}/token"\
        "?grant_type=refresh_token"\
        "&refresh_token=#{@external_refresh_token}"\
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
    end
    if !@external_access_token
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
      puts "#..did NOT obtain external URL for RESTn" 
    end
    @external_session_key
  end

  def external_session_key
    @external_session_key ||= acquire_external_session_key
  end

  def external_url_rest
    @external_url_rest
  end


end
