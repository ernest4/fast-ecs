# fast-ecs [wip]

This is an [Entity Component System (ECS)](https://en.wikipedia.org/wiki/Entity_component_system) that aims to be as fast as possible, to support as big
workloads as possible.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     fast-ecs:
       github: ernest4/fast-ecs
   ```

2. Run `shards install`

## Usage

```crystal
require "fast-ecs"

# define components
class TransformComponent < Fast::ECS::Component
  property :x, :y

  def initialize(id : Int32, x : Int32, y : Int32)
    super(id)
    @x = x
    @y = y
  end
end

class VelocityComponent < Fast::ECS::Component
  property :x, :y

  def initialize(id : Int32, x : Int32, y : Int32)
    super(id)
    @x = x
    @y = y
  end
end

# define systems
class ManagerSystem < Fast::ECS::System
  def start
    # runs once system is added

    # create some entities
    entity_id1 = engine.generate_entity_id
    transform1 = TransformComponent.new(entity_id1, 0, 0)
    velocity1 = VelocityComponent.new(entity_id1, 5, 10)
    engine.add_component(transform1)
    engine.add_component(velocity1)

    entity_id2 = engine.generate_entity_id
    transform2 = TransformComponent.new(entity_id2, 1, 2)
    velocity2 = VelocityComponent.new(entity_id2, 50, 5)
    engine.add_component(transform2)
    engine.add_component(velocity2)
  end

  def update
    # runs every time the engine.update is called
  end

  def destroy
    # runs once system is removed
  end
end

class MovementSystem < Fast::ECS::System
  def start
    # runs once system is added
  end

  def update
    # runs every time the engine.update(<delta_time>) is called

    # perform a query to find all entities that have all the components you're looking for
    engine.query(TransformComponent, VelocityComponent) do |query_set|
      transform, velocity = query_set

      seconds = delta_time / 1000;

      transform.x += velocity.x * seconds;
      transform.y += velocity.y * seconds;
    end
  end

  def destroy
    # runs once system is removed
  end
end

# create engine, add systems
engine = Fast::ECS::Engine.new
engine.add_system(ManagerSystem.new)
engine.add_system(MovementSystem.new)

# run an engine update tick, passing in the delta_time between frames.
engine.update(50) # normally, you'll have your own tick provider call update.
```

For more methods for components and systems, please check out [fast_ecs/Engine.cr](https://github.com/ernest4/fast-ecs/blob/master/src/fast_ecs/engine.cr)

## TODO
- [x] entity id pool
  - [x] import_entity_id_pool(params)
  - [x] export_entity_id_pool
- [ ] systems
  - [x] add_system(system : System)
  - [ ] add_systems(*system : System)
  - [ ] add_systems(system : Array(System))
  - [ ] get_system(  to be determined  )
  - [ ] disable_system(system : System)
  - [ ] disable_systems(*system : System)
  - [ ] disable_systems(system : Array(System))
  - [ ] remove_system(system : System)
  - [ ] remove_systems(*system : System)
  - [ ] remove_systems(system : Array(System))
  - [ ] remove_all_systems
- [ ] components
  - [x] add_component(component : Component)
  - [x] add_components(*components : Component)
  - [x] add_components(components : Array(Component))
  - [x] remove_component(component : Component)
  - [x] remove_component(component_class : Component.class, entity_id : Int32)
  - [x] remove_components(*components : Component)
  - [x] remove_components(components : Array(Component))
  - [x] get_component(component_class : Component.class, entity_id : Int32)
  - [x] get_components(entity_id : Int32)
  - [ ] get_components(*entity_id : Int32)
  - [ ] get_components(entity_id : Array(Int32))
- entity
  - [ ] create_entity
  - [x] generate_entity_id
  - [x] remove_entity(entity_id : Int32)
  - [ ] remove_entities(*entity_id : Int32)
  - [ ] remove_entities(entity_id : Array(Int32))
  - [x] remove_all_entities
    - [ ] entity class
      - [ ] id
      - [ ] components
- [x] update(delta_time : Int32) # in milliseconds
- [ ] update(delta_time : Time::Span)
- [ ] queries
  - [x] query(*component_classes : Component.class) # default AND query
  - [ ] query(component_classes : Array(Component.class)) # default AND query
  - [ ] or_query(*component_classes : Component.class)
  - [ ] or_query(component_classes : Array(Component.class))
  - [ ] not_query(*component_classes : Component.class)
  - [ ] not_query(component_classes : Array(Component.class))

## Contributing

1. Fork it (<https://github.com/your-github-user/fast-ecs/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Ernestas Monkevicius](https://github.com/your-github-user) - creator and maintainer
