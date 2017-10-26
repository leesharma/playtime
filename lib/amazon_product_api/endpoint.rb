# frozen_string_literal: true

module AmazonProductAPI
  # Base representation of all Amazon Product Advertising API endpoints.
  #
  # http://docs.aws.amazon.com/AWSECommerceService/latest/DG/\
  #   CHAP_OperationListAlphabetical.html
  #
  # Any general logic relating to lookup, building the query string,
  # authentication signatures, etc. should live in this class. Specializations
  # (including specific request parameters and response parsing) should live in
  # endpoint subclasses.
  class Endpoint
    require 'httparty'
    require 'time'
    require 'uri'
    require 'openssl'
    require 'base64'

    # The region you are interested in
    ENDPOINT    = 'webservices.amazon.com'
    REQUEST_URI = '/onca/xml'

    # Generates the signed URL
    def url
      raise InvalidQueryError, 'Missing AWS credentials' unless aws_credentials

      "http://#{ENDPOINT}#{REQUEST_URI}" +    # base
        "?#{canonical_query_string}" +        # query
        "&Signature=#{uri_escape(signature)}" # signature
    end

    # Sends the HTTP request
    def get(http: HTTParty)
      http.get(url)
    end

    # Performs the search query and returns the processed response
    def response(http: HTTParty, logger: Rails.logger)
      response = parse_response get(http: http)
      logger.debug response
      process_response(response)
    end

    private

    attr_reader :aws_credentials

    # Takes the response hash and returns the processed API response
    #
    # This must be implemented for each individual endpoint.
    def process_response(_response_hash)
      raise NotImplementedError, 'Implement this method in your subclass.'
    end

    # Returns a hash of request parameters unique to the endpoint
    #
    # This must be implemented for each individual endpoint.
    def request_params
      raise NotImplementedError, 'Implement this method in your subclass.'
    end

    def params
      params = request_params.merge(
        'Service'         => 'AWSECommerceService',
        'AWSAccessKeyId'  => aws_credentials.access_key,
        'AssociateTag'    => aws_credentials.associate_tag
      )

      # Set current timestamp if not set
      params['Timestamp'] ||= Time.now.gmtime.iso8601
      params
    end

    def parse_response(response)
      Hash.from_xml(response.body)
    end

    # Generates the signature required by the Product Advertising API
    def signature
      Base64.encode64(digest_with_key(string_to_sign)).strip
    end

    def string_to_sign
      "GET\n#{ENDPOINT}\n#{REQUEST_URI}\n#{canonical_query_string}"
    end

    def canonical_query_string
      params.sort
            .map { |key, value| "#{uri_escape(key)}=#{uri_escape(value)}" }
            .join('&')
    end

    def digest_with_key(string)
      OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'),
                           aws_credentials.secret_key,
                           string)
    end

    def uri_escape(phrase)
      CGI.escape(phrase.to_s)
    end
  end
end
