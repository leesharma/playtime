# frozen_string_literal: true

# Mocks an AWS Credentials object
AWSTestCredentials = Struct.new(:access_key,
                                :secret_key,
                                :associate_tag)
