require "./spec_helper"

Spectator.describe Fast::ECS::EntityIdPool do
  subject { described_class.new }

  describe "#reclaim_id" do
    let(:id) { 5 }

    before_each { subject.reclaim_id(id) }

    it "adds id to reclaimed pool" do
      expect(subject.get_id).to eq id
    end

    it "increases reclaimed id pool size" do
      expect(subject.size).to eq 1
    end
  end

  describe "#get_id" do
    context "when pool is empty" do
      it "generates new ids, starting at 0 and pool size doesn't grow" do
        expect(subject.get_id).to eq 0
        expect(subject.size).to eq 0

        expect(subject.get_id).to eq 1
        expect(subject.size).to eq 0

        expect(subject.get_id).to eq 2
        expect(subject.size).to eq 0
      end
    end

    context "when pool has reclaimed some ids" do
      it "uses the pool, once pool exhausted, generates new ids" do
        [0, 1, 2, 3, 4, 5].each do |id|
          expect(subject.get_id).to eq id
          expect(subject.size).to eq 0
        end

        subject.reclaim_id(1)
        expect(subject.size).to eq 1

        subject.reclaim_id(4)
        expect(subject.size).to eq 2

        subject.reclaim_id(5)
        expect(subject.size).to eq 3

        expect(subject.get_id).to eq 5
        expect(subject.size).to eq 2

        expect(subject.get_id).to eq 4
        expect(subject.size).to eq 1

        expect(subject.get_id).to eq 1
        expect(subject.size).to eq 0

        expect(subject.get_id).to eq 6
        expect(subject.size).to eq 0

        expect(subject.get_id).to eq 7
        expect(subject.size).to eq 0
      end
    end
  end

  describe "#clear" do
    before_each do
      [subject.get_id, subject.get_id, subject.get_id].each do |id|
        subject.reclaim_id(id)
      end
    end

    it "returns pool size" do
      expect(subject.clear).to eq 3
    end

    it "sets size to 0" do
      subject.clear
      expect(subject.size).to eq 0
    end

    it "generates a new id" do
      subject.clear
      expect(subject.get_id).to eq 0
    end
  end

  describe "#state" do
    let(:last_used_entity_id) { 5 }
    let(:reclaimed_entity_id_pool) { [1, 3, 5] }
    let(:reclaimed_entity_id_pool_size) { reclaimed_entity_id_pool.size }

    let(:expected_state) do
      {
        :last_used_entity_id           => last_used_entity_id,
        :reclaimed_entity_id_pool      => reclaimed_entity_id_pool,
        :reclaimed_entity_id_pool_size => reclaimed_entity_id_pool_size,
      }
    end

    before_each do
      (last_used_entity_id + 1).times { subject.get_id }
      reclaimed_entity_id_pool.each { |id| subject.reclaim_id(id) }
    end

    it "returns internal state" do
      expect(subject.state).to eq expected_state
    end
  end
end
