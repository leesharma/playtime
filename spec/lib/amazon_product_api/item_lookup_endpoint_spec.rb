# frozen_string_literal: true

require 'amazon_product_api/item_lookup_endpoint'
require 'support/helpers/amazon_helpers'

describe AmazonProductAPI::ItemLookupEndpoint do
  let(:aws_credentials) {
    AWSTestCredentials.new('aws_access_key',
                           'aws_secret_key',
                           'aws_associates_tag')
  }

  context 'with one asin' do
    let(:query) {
      AmazonProductAPI::ItemLookupEndpoint.new('corgi_asin', aws_credentials)
    }

    describe '#url' do
      subject(:url) { query.url }

      it { should start_with 'http://webservices.amazon.com/onca/xml' }
      it { should include 'AWSAccessKeyId=aws_access_key' }
      it { should include 'AssociateTag=aws_associates_tag' }
      it { should include 'Operation=ItemLookup' }
      it { should include 'ItemId=corgi_asin' }
      it { should include 'ResponseGroup=ItemAttributes%2COffers%2CImages' }
      it { should include 'Service=AWSECommerceService' }
      it { should include 'Timestamp=' }
      it { should include 'Signature=' }
    end

    describe '#get' do
      let(:http_double) { double('http') }

      it 'should make a `get` request to the specified http library' do
        expect(http_double).to receive(:get).with(String)
        query.get(http: http_double)
      end
    end

    describe '#response', :external do
      subject(:items) { query.response }
      let(:item) { items.first }

      it 'should have one entry' do
        expect(items.count).to eq 1
      end

      it 'should have the item information' do
        expect(item.asin).to eq 'B00TFT77ZS'
        expect(item.title).to eq 'Douglas Toys Louie Corgi'
        expect(item.price_cents).to eq 1350
      end
    end
  end

  context 'with multiple asins' do
    let(:query) {
      AmazonProductAPI::ItemLookupEndpoint.new('corgi_asin',
                                               'corgi_asin2',
                                               aws_credentials)
    }

    describe '#url' do
      subject(:url) { query.url }
      it { should include 'ItemId=corgi_asin%2Ccorgi_asin2' }
    end

    describe '#response', :external do
      subject(:items) { query.response }

      it 'should have two entries' do
        expect(items.count).to eq 2
      end

      it 'should have the item information' do
        expect(items.first.asin).to eq 'B00TFT77ZS'
        expect(items.second.asin).to eq 'B005R46A6W'
      end
    end
  end

  context 'for more than ten asins' do
    it 'raises an argument error' do
      expect {
        AmazonProductAPI::ItemLookupEndpoint.new(*('1'..'11'), aws_credentials)
      }.to raise_error(ArgumentError)
    end
  end
end
