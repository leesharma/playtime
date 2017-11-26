# frozen_string_literal: true

describe ItemSyncJob do
  describe '#perform' do
    context 'for zero items' do
      it 'runs successfully' do
        expect { subject.perform }.not_to raise_error
      end
    end

    context 'for one item', :external do
      let!(:corgi) { create(:item, asin: 'corgi_asin') }

      context 'when an item is unchanged' do
        before { subject.perform }

        it 'keeps the original item' do
          expect { subject.perform }.not_to change { corgi.reload.attributes }
        end
      end

      context 'when an item is changed' do
        it 'updates the item name' do
          expect { subject.perform }.to change { corgi.reload.name }
        end

        it 'updates the item price' do
          expect { subject.perform }.to change { corgi.reload.price_cents }
        end

        it 'updates the item url' do
          expect { subject.perform }.to change { corgi.reload.amazon_url }
        end

        it 'updates the item image url' do
          expect { subject.perform }.to change { corgi.reload.image_url }
        end
      end
    end

    context 'for multiple items', :external do
      let!(:item_1) { create(:item, asin: 'corgi_asin') }
      let!(:item_2) { create(:item, asin: 'corgi_asin2') }

      it 'updates the first item' do
        expect { subject.perform }.to change { item_1.reload.attributes }
      end

      it 'updates the second item' do
        expect { subject.perform }.to change { item_2.reload.attributes }
      end
    end
  end
end
