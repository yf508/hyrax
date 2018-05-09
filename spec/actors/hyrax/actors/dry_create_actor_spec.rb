# frozen_string_literal: true
RSpec.describe Hyrax::Actors::DryCreateActor do
  subject(:actor)  { described_class.new(next_actor) }
  let(:next_actor) { SpyActor.new }
  let(:ability)    { :no_ability }
  let(:attrs)      { {} }
  let(:env)        { Hyrax::Actors::Environment.new(work, ability, attrs) }
  let(:work)       { build(:generic_work) }

  before do
    Hyrax::PermissionTemplate
      .create!(source_id: AdminSet.find_or_create_default_admin_set_id)
  end

  describe '#create' do
    shared_context 'when create fails' do
      subject(:actor) do
        described_class.new(next_actor, transaction: tx, error_handler: handler)
      end

      let(:handler) { -> err { Rails.logger.info "Error Handled! #{err}" } }

      let(:tx) do
        Hyrax::Transactions::CreateWork
          .new(save_work: ->(x) { Dry::Monads::Result::Failure.new(:no_save) })
      end
    end

    it 'returns true' do
      expect(actor.create(env)).to be_truthy
    end

    it 'does not reach the next actor' do
      expect { actor.create(env) }
        .not_to change { next_actor.created }
    end

    it 'creates the work' do
      expect { actor.create(env) }
        .to change { work.persisted? }
        .from(false)
        .to(true)
    end

    context 'when the work fails to persist' do
      include_context 'when create fails'

      it 'returns false' do
        expect(actor.create(env)).to be_falsey
      end

      it 'does not create the work' do
        expect { actor.create(env) }
          .not_to change { work.persisted? }
          .from(false)
      end

      it 'sends to error handler' do
        expect(Rails.logger).to receive(:info).with('Error Handled! no_save')

        actor.create(env)
      end
    end

    context 'with attributes' do
      let(:work) { GenericWork.new }

      let(:attrs) do
        attributes_for(:generic_work, creator: ['Moomin'], subject: ['Snorks'])
      end

      it 'applies the attributes' do
        actor.create(env)

        expect(work).to have_attributes(attrs)
      end
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
    it 'passes through to next actor' do
      expect { actor.destroy(env) }
        .to change { next_actor.destroyed }
        .to true
    end
  end
end
