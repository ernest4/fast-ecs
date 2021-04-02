require "./spec_helper"

class TestySystem < Fast::ECS::System
  def start
    # Testing
  end

  def update
    # Testing
  end

  def destroy
    # Testing
  end
end

class TestyComponentA < Fast::ECS::Component
  property :stringy

  def initialize(id : Int32, stringy : String)
    super(id)
    @stringy = stringy
  end
end

class TestyComponentB < Fast::ECS::Component
  property :number

  def initialize(id : Int32, number : Int32)
    super(id)
    @number = number
  end
end

Spectator.describe Fast::ECS::Engine do
  mock TestySystem do
    # stub instance_method(some_number : Int32)
    # stub self.class_method(some_string : String)
    stub add_engine(engine : Fast::ECS::Engine)
    stub start
    stub update
    stub destroy
  end

  mock Fast::ECS::Engine do
    stub add_component(component : Component)
    stub remove_component(component : Component)
  end

  let(:testy_system1) { TestySystem.new }
  let(:testy_system2) { TestySystem.new }
  let(:testy_system3) { TestySystem.new }

  let(:testy_component_a1) { TestyComponentA.new(subject.generate_entity_id, "abc") }
  let(:testy_component_a2) { TestyComponentA.new(subject.generate_entity_id, "def") }
  let(:testy_component_a3) { TestyComponentA.new(subject.generate_entity_id, "ghi") }

  subject { described_class.new }

  describe "#add_system" do
    let(:add_systems) do
      subject.add_system(testy_system1)
      subject.add_system(testy_system2)
      subject.add_system(testy_system3)
    end

    it "adds the system" do
      add_systems

      expect(subject.systems).to eq [testy_system1, testy_system2, testy_system3]
    end

    it "adds the engine reference to system" do
      [testy_system1, testy_system2, testy_system3].each do |testy_system|
        expect(testy_system).to receive(:add_engine).with(subject)
      end

      add_systems
    end

    it "calls system#start" do
      [testy_system1, testy_system2, testy_system3].each do |testy_system|
        expect(testy_system).to receive(:start)
      end

      add_systems
    end
  end

  describe "#generate_entity_id" do
    it "returns entity id" do
      expect(subject.generate_entity_id).to eq 0
      expect(subject.generate_entity_id).to eq 1
      expect(subject.generate_entity_id).to eq 2
    end
  end

  describe "#add_component" do
    before_each do
      subject.add_component(testy_component_a1)
    end

    context "when component doesn't exist" do
      it "adds the component" do
        expect(subject.get_component(TestyComponentA, testy_component_a1.id)).to eq testy_component_a1
      end
    end

    it "returns the component" do
      expect(subject.add_component(testy_component_a2)).to eq testy_component_a2
    end

    # context "when component does exist" do
    #   it "adds the component once" do
    #     # TODO: ...
    #   end
    # end
  end

  describe "#add_components" do
    let(:testy_component_b1) { TestyComponentB.new(testy_component_a1.id, 123) }
    let(:testy_components) { [testy_component_a1, testy_component_a2, testy_component_b1] }

    it "calls remove_component for each of the components" do
      testy_components.each do |testy_component|
        expect(subject).to receive(:add_component).with(testy_component)
      end

      subject.add_components(testy_component_a1, testy_component_a2, testy_component_b1)
    end

    it "works with array" do
      testy_components.each do |testy_component|
        expect(subject).to receive(:add_component).with(testy_component)
      end

      subject.add_components(testy_components)
    end
  end

  describe "#remove_component" do
    context "when a component doesn't exist" do
      it "doesn't raise an error" do
        expect(subject.remove_component(TestyComponentA.new(123456, "abc"))).not_to raise_error
      end
    end

    context "when component exists" do
      before_each do
        subject.add_component(testy_component_a1)
      end

      it "removes the component" do
        expect(subject.get_component(TestyComponentA, testy_component_a1.id)).to eq testy_component_a1
        subject.remove_component(testy_component_a1)
        expect(subject.get_component(TestyComponentA, testy_component_a1.id)).to eq nil
      end

      it "reclaims entity_id" do
        removed_component_id = testy_component_a1.id
        subject.remove_component(testy_component_a1)
        expect(subject.generate_entity_id).to eq removed_component_id
      end

      context "when another component has the same id" do
        before_each { subject.add_component(TestyComponentB.new(testy_component_a1.id, 123)) }

        it "does not reclaim the id" do
          removed_component_id = testy_component_a1.id
          subject.remove_component(testy_component_a1)
          expect(subject.generate_entity_id).not_to eq removed_component_id
        end
      end

      context "when using component class and id" do
        it "removes the component" do
          expect(subject.get_component(TestyComponentA, testy_component_a1.id)).to eq testy_component_a1
          subject.remove_component(TestyComponentA, testy_component_a1.id)
          expect(subject.get_component(TestyComponentA, testy_component_a1.id)).to eq nil
        end
      end
    end
  end

  describe "#remove_components" do
    let(:testy_component_b1) { TestyComponentB.new(testy_component_a1.id, 123) }
    let(:testy_components) { [testy_component_a1, testy_component_a2, testy_component_b1] }

    it "calls remove_component for each of the components" do
      testy_components.each do |testy_component|
        expect(subject).to receive(:remove_component).with(testy_component)
      end

      subject.remove_components(testy_component_a1, testy_component_a2, testy_component_b1)
    end

    it "works with array" do
      testy_components.each do |testy_component|
        expect(subject).to receive(:remove_component).with(testy_component)
      end

      subject.remove_components(testy_components)
    end
  end

  describe "#get_component" do
    context "when component exists" do
      before_each do
        subject.add_component(testy_component_a1)
      end

      it "returns component" do
        expect(subject.get_component(TestyComponentA, testy_component_a1.id)).to eq testy_component_a1
      end
    end

    context "when component does not exist" do
      it "returns nil" do
        expect(subject.get_component(TestyComponentA, testy_component_a1.id)).to eq nil
      end
    end
  end

  describe "#get_components" do
    let(:testy_component_b1) { TestyComponentB.new(testy_component_a1.id, 123) }

    before_each do
      subject.add_component(testy_component_a1)
      subject.add_component(testy_component_b1)
    end

    it "returns all components for entity_id" do
      expect(subject.get_components(testy_component_a1.id))
        .to eq [testy_component_a1, testy_component_b1]
    end

    context "when some components missing" do
      before_each do
        subject.remove_component(testy_component_a1)        
      end

      it "returns any components it has" do
        expect(subject.get_components(testy_component_a1.id)).to eq [testy_component_b1]
      end
    end
  end

  describe "#remove_entity" do
    let(:entity_id) { testy_component_a1.id }
    let(:testy_component_b1) { TestyComponentB.new(entity_id, 123) }

    before_each do
      subject.add_component(testy_component_a1)
      subject.add_component(testy_component_b1)
    end

    it "removes all components associated with that entity_id" do
      expect { subject.remove_entity(entity_id) }
        .to change { subject.get_components(entity_id) }
        .from([testy_component_a1, testy_component_b1]).to([] of Fast::ECS::Component)
    end

    it "reclaims entity_id" do
      subject.remove_entity(entity_id)
      expect(subject.generate_entity_id).to eq entity_id
    end
  end

  describe "#remove_all_entities" do
    let(:entity_id) { testy_component_a1.id }
    let(:testy_component_b1) { TestyComponentB.new(entity_id, 123) }

    let(:entity_id2) { testy_component_a2.id }
    let(:testy_component_b2) { TestyComponentB.new(entity_id2, 123) }

    before_each do
      subject.add_component(testy_component_a1)
      subject.add_component(testy_component_b1)

      subject.add_component(testy_component_a2)
      subject.add_component(testy_component_b2)
    end

    it "removes all components" do
      expect { subject.remove_all_entities }
        .to change { subject.get_components(entity_id) + subject.get_components(entity_id2) }
        .from(
          [testy_component_a1, testy_component_b1, testy_component_a2, testy_component_b2]
        ).to([] of Fast::ECS::Component)
    end

    it "starts entity_id count from zero" do
      subject.remove_all_entities
      expect(subject.generate_entity_id).to eq 0
    end
  end

  describe "#update" do
    let(:delta_time) { 123 }

    before_each do
      subject.add_system(testy_system1)
      subject.add_system(testy_system2)
      subject.add_system(testy_system3)
    end

    let(:update_engine) { subject.update(delta_time) }

    it "updates all added systems" do
      [testy_system1, testy_system2, testy_system3].each do |testy_system|
        expect(testy_system).to receive(:update)
      end

      update_engine
    end

    it "exposes delta_time in systems" do
      update_engine

      [testy_system1, testy_system2, testy_system3].each do |testy_system|
        expect(testy_system.delta_time).to eq delta_time
      end
    end
  end

  describe "#query" do
    let(:testy_component_b1) { TestyComponentB.new(testy_component_a1.id, 123) }
    let(:testy_component_b2) { TestyComponentB.new(testy_component_a2.id, 123) }

    context "when there is at least one entity with requested components" do
      before_each do
        subject.add_component(testy_component_a1)
        subject.add_component(testy_component_b1)
      end

      it "does finds those components" do
        components = [] of Array(Fast::ECS::Component)

        subject.query(TestyComponentA, TestyComponentB) do |query_set|
          compA, compB = query_set
          components.push([compA, compB])
        end

        expect(components).to eq [[testy_component_a1, testy_component_b1]]
      end
    end

    context "when there is more than one entity with requested components" do
      before_each do
        subject.add_component(testy_component_a1)
        subject.add_component(testy_component_b1)

        subject.add_component(testy_component_a2)
        subject.add_component(testy_component_b2)

        subject.add_component(testy_component_a3)
      end

      it "does finds those components (match 2)" do
        components = [] of Array(Fast::ECS::Component)

        subject.query(TestyComponentA, TestyComponentB) do |query_set|
          compA, compB = query_set
          components.push([compA, compB])
        end

        expect(components).to eq [
          [testy_component_a1, testy_component_b1],
          [testy_component_a2, testy_component_b2]
        ]
      end

      it "does finds those components (match 3)" do
        components = [] of Array(Fast::ECS::Component)

        # also example of passing in a callback block. This can come from helper function or w.e.
        block = ->(query_set : Array(Fast::ECS::Component)) do
          compA = query_set.first
          components.push([compA])
        end

        subject.query(TestyComponentA, &block)

        expect(components).to eq [[testy_component_a1], [testy_component_a2], [testy_component_a3]]
      end
    end

    context "when there are no components" do
      it "does not find any components" do
        components = [] of Array(Fast::ECS::Component)

        subject.query(TestyComponentA, TestyComponentB) do |query_set|
          compA, compB = query_set
          components.push([compA, compB])
        end

        expect(components.size).to eq 0
      end
    end

    context "when one component is missing" do
      before_each do
        subject.add_component(testy_component_a1)
      end

      it "does not find any components" do
        components = [] of Array(Fast::ECS::Component)

        subject.query(TestyComponentA, TestyComponentB) do |query_set|
          compA, compB = query_set
          components.push([compA, compB])
        end

        expect(components.size).to eq 0
      end
    end
  end

  describe "#delta_time" do
    let(:delta_time) { 123 }

    before_each { subject.update(delta_time) }

    it "returns delta_time" do
      expect(subject.delta_time).to eq delta_time
    end
  end
end
