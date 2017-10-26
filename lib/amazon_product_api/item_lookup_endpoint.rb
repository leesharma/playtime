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
    def initialize(asin, aws_credentials)
      @asin = asin
      @aws_credentials = aws_credentials
    end

    private

    attr_reader :asin, :aws_credentials

    def process_response(response_hash)
      LookupResponse.new(response_hash).item
    end

    # Other request parameters for ItemLookup can be found here:
    #
    #   http://docs.aws.amazon.com/AWSECommerceService/latest/DG/\
    #     ItemLookup.html#ItemLookup-rp
    def request_params
      {
        'Operation'       => 'ItemLookup',
        'ResponseGroup'   => 'ItemAttributes,Offers,Images',
        'ItemId'          => asin.to_s
      }
    end
  end
end
