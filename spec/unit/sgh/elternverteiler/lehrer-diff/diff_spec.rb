# frozen_string_literal: true

require 'spec_helper'

require 'sgh/elternverteiler/lehrer-diff/diff'

describe LehrerDiff::Diff do
  subject { described_class.new(current, incoming) }

  let(:current) { eager_load_fixture }
  let(:incoming) { eager_load_fixture }

  # provide a fresh copy (deep clone) that
  # we can mangle without side effects
  def eager_load_fixture
    YAML.load_file(fixture('lehrer.yml'))
  end

  shared_examples(:no_changes) do
    it 'has no changes' do
      expect(subject.changes?).to be_falsey
    end
  end

  shared_examples(:some_changes) do
    it 'has some changes' do
      expect(subject.changes?).to be_truthy
    end
  end

  shared_examples(:no_additions) do
    it 'has no additions' do
      expect(subject.additions?).to be_falsey
    end
  end

  shared_examples(:some_additions) do
    it 'has some additions' do
      expect(subject.additions?).to be_truthy
    end
  end

  shared_examples(:no_removals) do
    it 'has no removals' do
      expect(subject.removals?).to be_falsey
    end
  end

  shared_examples(:some_removals) do
    it 'has some removals' do
      expect(subject.removals?).to be_truthy
    end
  end

  context 'everything is the same' do
    it_behaves_like(:no_changes)
    it_behaves_like(:no_additions)
    it_behaves_like(:no_removals)
  end

  context 'Mrs. Krabappel joins the school' do
    let(:incoming) do
      eager_load_fixture.append(
        {
          kürzel: 'ek',
          nachname: 'Krabappel',
          vorname: 'Edna',
          fächer: ['E', 'BK'],
        }
      )
    end

    it_behaves_like(:no_changes)
    it_behaves_like(:some_additions)
    it_behaves_like(:no_removals)

    it 'has non-empty additions' do
      expect(subject.additions).not_to be_empty
    end

    it 'has exactly one addition' do
      expect(subject.additions.size).to eq(1)
    end

    context 'first addition' do
      let(:addition) { subject.additions.first }

      it 'has the path of the addition' do
        expect(addition).to respond_to(:path)
      end

      it 'has the subject of the addition' do
        expect(addition).to respond_to(:subject)
        expect(addition.subject[:kürzel]).to eq('ek')
        expect(addition.subject[:nachname]).to eq('Krabappel')
        expect(addition.subject[:vorname]).to eq('Edna')
        expect(addition.subject[:fächer]).to eq(%w[E BK])
      end
    end
  end

  context 'Mrs. Dellert changes her last name' do
    let(:incoming) do
      eager_load_fixture.tap do |all|
        all.select { |l| l[:kürzel] == 'Del' }.first[:nachname] = 'Mustermann'
      end
    end

    it_behaves_like(:some_changes)
    it_behaves_like(:no_additions)
    it_behaves_like(:no_removals)

    it 'has non-empty changes' do
      expect(subject.changes).not_to be_empty
    end

    it 'has exactly one change' do
      expect(subject.changes.size).to eq(1)
    end

    context 'first change' do
      let(:change) { subject.changes.first }

      it 'has the path of the change' do
        expect(change).to respond_to(:path)
      end

      it 'has the subject of the change'

      it 'has the old value of the change' do
        expect(change).to respond_to(:old)
        expect(change.old).to eq('Dellert')
      end

      it 'has the new value of the change' do
        expect(change).to respond_to(:new)
        expect(change.new).to eq('Mustermann')
      end
    end
  end

  context 'Mr. Prior leaves the school' do
    let(:incoming) do
      eager_load_fixture.tap do |all|
        all.delete_if { |l| l[:kürzel] == 'Pr' }
      end
    end

    it_behaves_like(:no_changes)
    it_behaves_like(:no_additions)
    it_behaves_like(:some_removals)

    it 'has non-empty removals' do
      expect(subject.removals).not_to be_empty
    end

    it 'has exactly one removal' do
      expect(subject.removals.size).to eq(1)
    end

    context 'first removal' do
      let(:removal) { subject.removals.first }

      it 'has the path of the removal' do
        expect(removal).to respond_to(:path)
      end

      it 'has the subject of the removal' do
        expect(removal).to respond_to(:subject)
        expect(removal.subject[:kürzel]).to eq('Pr')
        expect(removal.subject[:nachname]).to eq('Prior')
        expect(removal.subject[:vorname]).to eq('Roland')
        expect(removal.subject[:fächer]).to eq(%w[E G])
      end
    end
  end
end
