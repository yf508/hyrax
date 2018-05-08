# frozen_string_literal: true
RSpec.describe Hyrax::Actors::DryDestroyActor do
  subject(:actor)  { described_class.new(next_actor) }
  let(:ability)    { :no_ability }
  let(:attrs)      { {} }
  let(:env)        { Hyrax::Actors::Environment.new(work, ability, attrs) }
  let(:next_actor) { spy_actor_class.new }
  let(:work)       { build(:generic_work) }

  let(:spy_actor_class) do
    Class.new do
      attr_accessor :created, :updated, :destroyed

      def create(_env)
        self.created = true
      end

      def update(_env)
        self.updated = true
      end

      def destroy(_env)
        self.destroyed = true
      end
    end
  end

  describe '#create' do
    it 'passes through to next actor' do
      expect { actor.create(env) }
        .to change { next_actor.created }
        .to true
    end
  end

  describe '#update' do
    it 'passes through to next actor' do
      expect { actor.update(env) }
        .to change { next_actor.updated }
        .to true
    end
  end

  describe '#destroy' do
    shared_context 'when destroy fails' do
      subject(:actor) do
        described_class.new(next_actor, transaction: tx, error_handler: handler)
      end

      let(:handler) { ->(err) { Rails.logger.info "Error Handled! #{err}" } }

      let(:tx) do
        Hyrax::Transactions::DestroyWork
          .new(destroy_work: ->(_x) { Dry::Monads::Result::Failure.new(:no_destroy) })
      end
    end

    it 'returns true' do
      expect(actor.destroy(env)).to be_truthy
    end

    context 'when destroy fails' do
      include_context 'when destroy fails'

      it 'sends to error handler' do
        expect(Rails.logger).to receive(:info).with('Error Handled! no_destroy')

        actor.destroy(env)
      end

      it 'returns false' do
        expect(actor.destroy(env)).to be_falsey
      end
    end

    context 'when the work exists' do
      let(:work) { create(:generic_work) }

      it 'does not reach next actor' do
        expect { actor.destroy(env) }
          .not_to change { next_actor.destroyed }
      end

      it 'returns true' do
        expect(actor.destroy(env)).to be_truthy
      end

      it 'destroys the work' do
        expect { actor.destroy(env) }
          .to change { work.destroyed? }
          .to true
      end

      context 'when work is featured' do
        let!(:features) do
          [FeaturedWork.create(work_id: work.id),
           FeaturedWork.create(work_id: work.id)]
        end

        it 'returns true' do
          expect(actor.destroy(env)).to be_truthy
        end

        it 'removes trophies for the work' do
          expect { actor.destroy(env) }
            .to change { FeaturedWork.where(work_id: work.id).any? }
            .to false
        end

        context 'and the destroy fails' do
          include_context 'when destroy fails'

          xit 'does not destroy trophies' do
            expect { actor.destroy(env) }
              .not_to change { FeaturedWork.where(work_id: work.id).count }
          end

          it 'returns false' do
            expect(actor.destroy(env)).to be_falsey
          end
        end
      end
    end
  end
end
