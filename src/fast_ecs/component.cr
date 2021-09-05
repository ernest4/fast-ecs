
# TODO: suggestion was to use flyweight pattern for components to increase RAM efficiency?
# https://refactoring.guru/design-patterns/flyweight

module Fast::ECS
  # NOTE: custom components will extend this.
  # NOTE: NO METHODS ON COMPONENTS !!!
  abstract class Component < SparseSet::Item
    def initialize(entity_id : Int32)
      super
    end
  end
end
