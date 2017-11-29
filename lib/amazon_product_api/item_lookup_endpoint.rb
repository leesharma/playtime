# frozen_string_literal: true

require 'amazon_product_api/endpoint'
require 'amazon_product_api/lookup_response'

module AmazonProductAPI
  # Responsible for looking up an item listing on Amazon
  #
  # http://docs.aws.amazon.com/AWSECommerceService/latest/DG/ItemLookup.html
  #
  # Contains all specialization logic for this endpoint including request
  # parameters, parameter validation, and response parsing.
  class ItemLookupEndpoint < Endpoint
    ASIN_LIMIT = 10 # max ASINs per request (from docs)

    def initialize(*asins, aws_credentials)
      validate_asin_count(asins)

      @asins = asins
      @aws_credentials = aws_credentials
    end

    private

    attr_reader :asins, :aws_credentials

    def validate_asin_count(asins)
      return unless asins.count > ASIN_LIMIT
      raise ArgumentError,
            "Exceeded maximum ASIN limit: #{asins.length}/#{ASIN_LIMIT}"
    end

    def process_response(response_hash)
      LookupResponse.new(response_hash).items
    end

    # Other request parameters for ItemLookup can be found here:
    #
    #   http://docs.aws.amazon.com/AWSECommerceService/latest/DG/\
    #     ItemLookup.html#ItemLookup-rp
    def request_params
      {
        'Operation'       => 'ItemLookup',
        'ResponseGroup'   => 'ItemAttributes,Offers,Images',
        'IdType'          => 'ASIN',
        'ItemId'          => asins.join(',')
      }
    end
  end
end
