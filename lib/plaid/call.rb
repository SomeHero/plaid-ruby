module Plaid
  class Call

    # This initializes our instance variables, and sets up a new Customer class.
    def initialize
      Plaid::Configure::KEYS.each do |key|
        instance_variable_set(:"@#{key}", Plaid.instance_variable_get(:"@#{key}"))
      end
    end

    def add_account(type,options,email)
      base_url = self.instance_variable_get(:'@base_url')
      path = "/connect"

      url = base_url + path

      @response = RestClient.post(url,
            :client_id => self.instance_variable_get(:'@customer_id'),
            :secret => self.instance_variable_get(:'@secret'),
            :type => type,
            :username => options[:username],
            :password => options[:password],
            :pin => options[:pin],
            :options => {
              :login_only => true,
              :webhook => options[:webhook]
            },
            :email => email
        ){ |response, request, result, &block|
          case response.code
          when 200
            response
          when 201
            response
          else
            response.return!(request, result, &block)
          end
        }

      return parse_response(@response)
    end

    def auth_account(type,options,email)
      @response = post('/auth',type,options,email)
      return parse_response(@response)
    end

    def get_place(id)
      @response = get('/entity',id)
      return parse_place(@response)
    end
    protected

    def parse_response(response)
      case response.code
      when 200
        @parsed_response = Hash.new
        @parsed_response[:code] = response.code
        response = JSON.parse(response)
        @parsed_response[:access_token] = response["access_token"]
        @parsed_response[:accounts] = response["accounts"]
        @parsed_response[:transactions] = response["transactions"]
        return @parsed_response
      when 201
        @parsed_response = Hash.new
        @parsed_response[:code] = response.code
        response = JSON.parse(response)
        @parsed_response = Hash.new
        @parsed_response[:type] = response["type"]
        @parsed_response[:access_token] = response["access_token"]
        @parsed_response[:mfa_info] = response["mfa"]
        return @parsed_response
      else
        @parsed_response = Hash.new
        @parsed_response[:code] = response.code
        @parsed_response[:message] = response
        return @parsed_response
      end
    end

    def parse_place(response)
      @parsed_response = Hash.new
      @parsed_response[:code] = response.code
      response = JSON.parse(response)["entity"]
      @parsed_response[:category] = response["category"]
      @parsed_response[:name] = response["name"]
      @parsed_response[:id] = response["_id"]
      @parsed_response[:phone] = response["meta"]["contact"]["telephone"]
      @parsed_response[:location] = response["meta"]["location"]
      return @parsed_response
    end

    private

    def post(path,type,options,email)
      base_url = self.instance_variable_get(:'@base_url')

      url = base_url + path
      RestClient.post(url,
            :client_id => self.instance_variable_get(:'@customer_id'),:secret => self.instance_variable_get(:'@secret'), :type => type ,:credentials => {:username => options[:username], :password => options[:password], :pin => options[:pin]} ,:email => email){ |response, request, result, &block|
          case response.code
          when 200
            response
          when 201
            response
          else
            response.return!(request, result, &block)
          end
      }

    end

    def get(path,id)
      base_url = self.instance_variable_get(:'@base_url')

      url = base_url + path
      RestClient.get(url,:params => {:entity_id => id}){ |response, request, result, &block|
          case response.code
          when 200
            response
          when 201
            response
          else
            response.return!(request, result, &block)
          end
      }
    end

  end
end
