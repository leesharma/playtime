# frozen_string_literal: true

require 'amazon_product_api'

# This job is responsible for syncing items with Amazon.
#
# Amazon changes prices, details, etc. pretty frequently, so this job will
# query the Amazon record associated with the ASIN and make any required local
# updates.
#
# Bang methods (ex. `#sync_batch!`) perform an HTTP request.
#
class ItemSyncJob < ApplicationJob
  # Maximum number of ASINs in one request
  BATCH_SIZE = AmazonProductAPI::ItemLookupEndpoint::ASIN_LIMIT

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

  # Syncs all database items with their Amazon sources
  def sync_all!
    # This is done in slices and batches to avoid Amazon rate limits
    Item.all.each_slice(BATCH_SIZE * 3) do |batches|
      batches.each_slice(BATCH_SIZE) { |batch| sync_batch! batch }
      sleep 2.seconds unless Rails.env.test?
    end
  end

  # Syncs one batch of items with Amazon (up to the batch size limit)
  def sync_batch!(items)
    count = items.count
    validate_batch_size(count)

    Rails.logger.info "Fetching #{count} items: #{items.map(&:asin).join(',')}"

    items_updates = get_updates_for! items
    items_updates.map { |item, updates| update_item(item, updates) }
  end

  # Returns pairs of items and their corresponding update hashes
  def get_updates_for!(items)
    query = client.item_lookup(*items.map(&:asin))
    amazon_items = query.response
    updates = amazon_items.map(&:update_hash)

    items.zip(updates)
  end

  def validate_batch_size(count)
    return unless count > BATCH_SIZE
    raise ArgumentError,
          "Batch size too large: #{count}/#{BATCH_SIZE}"
  end

  def update_item(item, update_hash)
    Rails.logger.info green(
      "Syncing item #{item.id}: (#{item.asin}) #{item.name.truncate(64)}"
    )
    item.assign_attributes(update_hash)
    return unless item.changed?

    Rails.logger.info bold_green("Changed:\n") + item.changes.pretty_inspect
    item.save!
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
