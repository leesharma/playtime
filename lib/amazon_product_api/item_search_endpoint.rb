# frozen_string_literal: true

require 'amazon_product_api/endpoint'
require 'amazon_product_api/search_response'

module AmazonProductAPI
  # Responsible for building and executing an Amazon Product API search query.
  #
  # http://docs.aws.amazon.com/AWSECommerceService/latest/DG/ItemSearch.html
  #
  # Contains all specialization logic for this endpoint including request
  # parameters, parameter validation, and response parsing.
  class ItemSearchEndpoint < Endpoint
    def initialize(query, page, aws_credentials)
      raise InvalidQueryError, "Page can't be nil." if page.nil?

      @query = query
      @page = page
      @aws_credentials = aws_credentials
    end

    private

    attr_accessor :query, :page, :aws_credentials

    def process_response(response_hash)
      SearchResponse.new response_hash
    end

    # Other request parameters for ItemLookup can be found here:
    #
    #   http://docs.aws.amazon.com/AWSECommerceService/latest/DG/\
    #     ItemSearch.html#ItemSearch-rp
    def request_params
      {
        'Operation'       => 'ItemSearch',
        'ResponseGroup'   => 'ItemAttributes,Offers,Images',
        'SearchIndex'     => 'All',
        'Keywords'        => query.to_s,
        'ItemPage'        => page.to_s
      }
    end
  end
end
