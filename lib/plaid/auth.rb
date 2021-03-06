module Plaid
  # This is used when a customer needs to be defined by the plaid access token.
  # Abstracting as a class makes it easier since we wont have to redefine the access_token over and over.
  class Auth

    # This initializes our instance variables, and sets up a new Customer class.
    def initialize
      Plaid::Configure::KEYS.each do |key|
        instance_variable_set(:"@#{key}", Plaid.instance_variable_get(:"@#{key}"))
      end
    end

    def retrieve(access_token)
      @response = post("/auth/get", access_token)
      return parse_response(@response,2)
    end

    def mfa_step(access_token,code, type)
      @mfa = code

      @response = post("/auth/step", access_token, { mfa: @mfa, type: type })
      return parse_response(@response,1)
    end

    def reauthenticate(access_token,type,username,password)

      @response = patch("/auth", access_token, type, username, password)
      return parse_response(@response, 1)
    end

    def get_transactions(access_token)
      @response = get('/auth', access_token)
      return parse_response(@response,2)
    end

    def delete_account(access_token)
      @response = delete('/auth', access_token)
      return parse_response(@response,3)
    end

    protected

    def parse_response(response,method)
      case method
      when 1
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
      when 2
        case response.code
        when 200
          @parsed_response = Hash.new
          @parsed_response[:code] = response.code
          response = JSON.parse(response)
          @parsed_response[:accounts] = response["accounts"]
          @parsed_response[:transactions] = response["transactions"]
          return @parsed_response
        else
          @parsed_response = Hash.new
          @parsed_response[:code] = response.code
          @parsed_response[:message] = response
          return @parsed_response
        end
      when 3
        case response.code
        when 200
          @parsed_response = Hash.new
          @parsed_response[:code] = response.code
          response = JSON.parse(response)
          @parsed_response[:message] = response
          return @parsed_response
        else
          @parsed_response = Hash.new
          @parsed_response[:code] = response.code
          @parsed_response[:message] = response
          return @parsed_response
        end
      end
    end

    private

    def get(path,access_token,options={})
      base_url = self.instance_variable_get(:'@base_url')

      url = base_url + path
      RestClient.get(url,:params => {:client_id => self.instance_variable_get(:'@customer_id'), :secret => self.instance_variable_get(:'@secret'), :access_token => access_token}){ |response, request, result, &block|
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

    def post(path,access_token,options={})
      base_url = self.instance_variable_get(:'@base_url')

      url = base_url + path
      RestClient.post url, :client_id => self.instance_variable_get(:'@customer_id') ,:secret => self.instance_variable_get(:'@secret'), :access_token => access_token, :mfa => @mfa, :type => options[:type]{ |response, request, result, &block|
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

    def patch(path,access_token,type,username,password,options={})
      base_url = self.instance_variable_get(:'@base_url')

      url = base_url + path
      RestClient.patch(url, :client_id => self.instance_variable_get(:'@customer_id') ,:secret => self.instance_variable_get(:'@secret'), :access_token => access_token, :type => type, :credentials => {:username => username, :password => password} ){ |response, request, result, &block|
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

    def delete(path,access_token,options={})
      base_url = self.instance_variable_get(:'@base_url')

      url = base_url + path
      RestClient.delete(url,:params => {:client_id => self.instance_variable_get(:'@customer_id'), :secret => self.instance_variable_get(:'@secret'), :access_token => access_token}){ |response, request, result, &block|
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
