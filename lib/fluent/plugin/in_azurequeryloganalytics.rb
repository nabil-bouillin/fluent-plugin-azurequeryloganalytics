require 'fluent/plugin/input'
require 'date'
require 'oauth2'

class AzureQueryLogAnalytics < Input
    Fluent::Plugin.register_input("azurequeryloganalytics", self)
    
    # Define parameters for API Monitor
    config_param :tag, :string, :default => "azurequeryloganalytics"
    config_param :tenant_id, :string, :default => nil
    config_param :subscription_id, :string, :default => nil
    config_param :client_id, :string, :default => nil
    config_param :client_secret, :string, :default => nil, :secret => true

    #config_param :select, :string, :default => nil
    #config_param :filter, :string, :default => "eventChannels eq 'Operation'"
    #config_param :api_version, :string, :default => nil

    def configure(conf)
        super
        #Oauth2 Azure Ad
        #Initializing a client
        client = OAuth2::Client.new('client_id', 'client_secret', :site =>'https://login.microsoftonline.com/someapp.com')
    
        #Creating a auth url
        auth_url = client.auth_code.authorize_url(:redirect_uri =>'https://someapp/login')
    
        #After auth_url is created, I then send a request to access the token
        token = client.auth_code.get_token('authorization_code_value', :redirect_uri => 'https://someapp/login', :headers => {'Authorization' => 'Basic some_password'})
        response = token.get('/api/resource', :params => { 'query_foo' => 'bar' })
        
    end

    def start
        super
        @finished = false
        @watcher = Thread.new(&method(:watch))
    end

    def shutdown
        super
        @finished = true
        @watcher.terminate
        @watcher.join
    end

    def set_query_options(filter, custom_headers)
        #fail ArgumentError, '@client.subscription_id is nil' if @client.subscription_id.nil?
  
        request_headers = {}
        request_headers['Content-Type'] = 'application/json; charset=utf-8'
  
        # Set Headers
        request_headers['x-ms-client-request-id'] = SecureRandom.uuid
        request_headers['accept-language'] = @client.accept_language unless @client.accept_language.nil?
  
        request_url = @client.base_url
        options = {
            middlewares: [[MsRest::RetryPolicyMiddleware, times: 3, retry: 0.02], [:cookie_jar]],
            path_params: {'subscriptionId' => @client.subscription_id},
            query_params: {'api-version' => @api_version,'$filter' => filter,'$select' => @select},
            headers: request_headers.merge(custom_headers || {}),
            base_url: request_url
        }
    end



    private
        def watch
            log.debug "azure query loganalytics: watch thread starting"
        
            @next_fetch_time = Time.now
        
            until @finished
            start_time = @next_fetch_time - @interval
            end_time = @next_fetch_time
            log.debug "start time: #{start_time}, end time: #{end_time}"
        
            monitor_logs_promise = get_monitor_log_async(filter)
            monitor_logs = monitor_logs_promise.value!
        
            if !monitor_logs.body['value'].nil? and  monitor_logs.body['value'].any?
                monitor_logs.body['value'].each {|val|
                #time = DateTime.parse(val['eventTimestamp'])
                #router.emit(@tag, Fluent::EventTime.from_time(time.to_time), val)
                }
            else
                log.debug "empty"
            end
            @next_fetch_time += @interval
            sleep @interval
            end
        end

