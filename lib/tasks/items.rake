# frozen_string_literal: true

namespace :items do
  desc 'Check Amazon listings and update local items accordingly.'
  task sync: :environment do
    ItemSyncJob.perform_now
  end
end
