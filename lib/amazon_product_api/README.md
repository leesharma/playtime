# Amazon Product Advertising API Client

This folder contains the wrapper code for the Amazon Product Advertising API.
For more details on the API, check the [Amazon documentation].

[Amazon documentation]: http://docs.aws.amazon.com/AWSECommerceService/latest/DG/Welcome.html

## Adding an Endpoint

All endpoints should be subclassed from `AmazonProductAPI::Endpoint`. In order
to add a new endpoint, you'll need to modify the template below in a few ways:

  * Prepend any new attributes to the `#initialize` parameter list. Any
    validations or processing can be done in `#initialize` as shown. Note:
    setting `aws_credentials` is **required**!

  * Add endpoint-specific request parameters to `#request_params`. These can
    be found in the Amazon API documentation.

  * Add any post-processing of the API response in `#process_response`.

  * Update the class name and comments.

### Endpoint Template

```ruby
require 'amazon_product_api/endpoint'

module AmazonProductAPI
  # Responsible for building and executing <...>
  #
  # <endpoint url>
  #
  # Contains all specialization logic for this endpoint including request
  # parameters, parameter validation, and response parsing.
  class TemplateEndpoint < Endpoint
    # Add any parameters you need for the specific endpoint.
    #
    # Make sure you set `@aws_credentials`-the query won't work without it!
    def initialize(aws_credentials)
      # Attribute validations
      # raise InvalidQueryError, 'reason' if ...

      # Initialize attributes
      @aws_credentials = aws_credentials
    end

    private

    attr_accessor :aws_credentials # any other attrs

    # Add any post-processing of the response hash.
    def process_response(response_hash)
      ExampleResponse.new(response_hash).item
    end

    # Include request parameters unique to this endpoint.
    def request_params
      {
        # 'Operation' => 'ItemLookup',
        # 'IdType' => 'ASIN',
        # 'ItemId' => 'the item asin',
        # ...
      }
    end
  end
end
```
