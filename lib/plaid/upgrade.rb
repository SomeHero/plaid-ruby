module Plaid
  # This is used when a customer needs to be defined by the plaid access token.
  # Abstracting as a class makes it easier since we wont have to redefine the access_token over and over.
  class Upgrade

    # This initializes our instance variables, and sets up a new Customer class.
    def initialize
      Plaid::Configure::KEYS.each do |key|
        instance_variable_set(:"@#{key}", Plaid.instance_variable_get(:"@#{key}"))
      end
    end

    def upgrade(access_token, upgrade_to)
      @response = post("/upgrade", access_token, { upgrade_to: upgrade_to })
      return parse_response(@response)
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
      else
        @parsed_response = Hash.new
        @parsed_response[:code] = response.code
        @parsed_response[:message] = response
        return @parsed_response
      end
    end

    private

    def post(path,access_token,options={})
      base_url = self.instance_variable_get(:'@base_url')

      url = base_url + path
      RestClient.post url, :client_id => self.instance_variable_get(:'@customer_id') ,:secret => self.instance_variable_get(:'@secret'), :access_token => access_token, :upgrade_to => options[:upgrade_to]{ |response, request, result, &block|
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
