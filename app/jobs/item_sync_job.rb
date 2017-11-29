# frozen_string_literal: true

require 'amazon_product_api'

# This job is responsible for syncing items with Amazon.
#
# Amazon changes prices, details, etc. pretty frequently, so this job will
# query the Amazon record associated with the ASIN and make any required local
# updates.
#
# Bang methods (ex. `#amazon_item!`) perform an HTTP request.
#
class ItemSyncJob < ApplicationJob
  queue_as :default

  def initialize
    @client = AmazonProductAPI::HTTPClient.new
  end

  # Syncs all items and writes the results to the log
  def perform(*_args)
    Rails.logger.info bold_green('Syncing all items')
    sync_all!
    Rails.logger.info bold_green('Done syncing!')
  end

  private

  attr_reader :client

  def sync_all!
    # This is done in slices to avoid Amazon rate limits
    Item.all.each_slice(3) do |items|
      items.each { |item| sync! item }
      sleep 2.seconds unless Rails.env.test?
    end
  end

  def sync!(item)
    Rails.logger.info green("Syncing item #{item.id}: #{item.name}")
    update_hash = amazon_item!(item).update_hash
    item.assign_attributes(update_hash)
    return unless item.changed?

    Rails.logger.info bold_green("Changed:\n") + item.changes.pretty_inspect
    item.save!
  end

  def amazon_item!(item)
    client.item_lookup(item.asin).response.first
  end

  # Some styles for log text. This is so minor that it's not worth
  # bringing in a full library.

  def bold_green(text)
    bold(green(text))
  end

  def green(text)
    "\e[32m#{text}\e[0m"
  end

  def bold(text)
    "\e[1m#{text}\e[22m"
  end
end
