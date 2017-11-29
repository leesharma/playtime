# frozen_string_literal: true

require 'amazon_product_api/search_item'

module AmazonProductAPI
  # Parses the Amazon Product API item lookup response
  #
  # Any logic that involves digging through the response hash should live in
  # this class. By isolating it from the rest of the codebase, we only have one
  # file to touch if the API response changes.
  class LookupResponse
    def initialize(response_hash)
      @response_hash = response_hash
    end

    def items(item_class: SearchItem)
      item_hashes.map { |hash| item_class.new(**item_attrs_from(hash)) }
    end

    private

    attr_reader :response_hash

    def item_attrs_from(hash)
      {
        asin: hash['ASIN'],

        detail_page_url: hash['DetailPageURL'],
        title:           hash['ItemAttributes']['Title'],
        price_cents:     hash['ItemAttributes']['ListPrice']['Amount'].to_i,

        image_url:    hash.dig('SmallImage', 'URL')    || '',
        image_width:  hash.dig('SmallImage', 'Width')  || '',
        image_height: hash.dig('SmallImage', 'Height') || ''
      }
    end

    def item_hashes
      items = response_hash.dig('ItemLookupResponse', 'Items', 'Item') || []
      items.is_a?(Array) ? items : [items] # wrap "naked" response
    end
  end
end
