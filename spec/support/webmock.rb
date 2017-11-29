# frozen_string_literal: true

require 'webmock/rspec'

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.before(:each, :external) do
    # Item Search

    search_response = file_fixture('amazon_corgi_search_response.xml').read
    stub_request(:get, 'webservices.amazon.com/onca/xml')
      .with(query: hash_including('Operation' => 'ItemSearch',
                                  'Keywords'  => 'corgi'))
      .to_return(body: search_response)

    # Single Item Lookup

    lookup_response = file_fixture('amazon_corgi_lookup_response.xml').read

    stub_request(:get, 'webservices.amazon.com/onca/xml')
      .with(query: hash_including('Operation' => 'ItemLookup',
                                  'ItemId'    => 'corgi_asin'))
      .to_return(body: lookup_response)

    stub_request(:get, 'webservices.amazon.com/onca/xml')
      .with(query: hash_including('Operation' => 'ItemLookup',
                                  'ItemId'    => 'corgi_asin2'))
      .to_return(body: lookup_response)

    # Dual Item Lookup

    dual_lookup_response = file_fixture('amazon_dual_lookup_response.xml').read

    stub_request(:get, 'webservices.amazon.com/onca/xml')
      .with(query: hash_including('Operation' => 'ItemLookup',
                                  'ItemId'    => 'corgi_asin,corgi_asin2'))
      .to_return(body: dual_lookup_response)
  end
end
