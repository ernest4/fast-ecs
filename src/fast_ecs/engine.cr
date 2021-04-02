module Fast::ECS
  class Engine
    getter :delta_time
    getter :systems

    def initialize(debug = false)
      @debug = debug
      @systems = [] of System
      @delta_time = 0
      @updating = false
      @component_lists = {} of String => SparseSet::SparseSet
      @entity_id_pool = EntityIdPool.new # TODO: add preload existing values logic
    end

    def import_entity_id_pool(params)
      @entity_id_pool = EntityIdPool.new({
        :last_used_entity_id           => params[:last_used_entity_id],
        :reclaimed_entity_id_pool      => params[:reclaimed_entity_id_pool],
        :reclaimed_entity_id_pool_size => params[:reclaimed_entity_id_pool_size],
      })
    end

    def export_entity_id_pool
      @entity_id_pool.state
    end

    def add_system(system : System)
      @systems.push(system)
      system.add_engine(self)
      system.start

      debug_log("[Engine]: Started system: #{system.class}")
    end

    # def get_system()
    #   # TODO: ...
    # end

    # def remove_system(system : System)
    #   # TODO: ... system.destroy
    # end

    # def disable_system(system : System)
    #   # TODO: keeps the system state, but skips it over for update
    # end

    # def remove_all_systems
    #   # TODO: ...
    # end

    def add_component(component : Component)
      component_class_name = component.class.to_s
      component_list = @component_lists[component_class_name]?

      if component_list.nil?
        component_list = SparseSet::SparseSet.new
        @component_lists[component_class_name] = component_list
      end

      component_list.add(component)

      component
    end

    def add_components(*components : Component)
      components.each { |component| add_component(component) } 
    end

    def add_components(components : Array(Component))
      components.each { |component| add_component(component) } 
    end

    def remove_component(component : Component)
      remove_component(component.class, component.id)
    end

    def remove_component(component_class : Component.class, entity_id : Int32)
      component_list = @component_lists[component_class.to_s]?
      return if component_list.nil?

      removed_id = component_list.remove(entity_id)
      reclaim_entity_id_if_free(entity_id) unless removed_id.nil?
    end

    def remove_components(*components : Component)
      components.each { |component| remove_component(component) } 
    end

    def remove_components(components : Array(Component))
      components.each { |component| remove_component(component) } 
    end

    def get_component(component_class : Component.class, entity_id : Int32)
      (@component_lists[component_class.to_s]?.try &.get(entity_id)).as(Component | Nil)
    end

    def get_components(entity_id : Int32)
      @component_lists.values.map do |component_list|
        component_list.get(entity_id)
      end.compact
    end

    # def create_entity
    #   # TODO: ...
    # end

    def generate_entity_id
      @entity_id_pool.get_id
    end

    def remove_entity(entity_id : Int32)
      @component_lists.values.map do |component_list|
        component_list.remove(entity_id)
      end

      reclaim_entity_id(entity_id)
    end

    def remove_all_entities
      @component_lists.values.map(&.clear)
      @entity_id_pool.clear
    end

    # def update(delta_time : Time::Span)
    def update(delta_time : Int32) # in milliseconds
      @delta_time = delta_time
      @updating = true
      @systems.each { |system| update_system(system) }
      @updating = false
    end

    def query(*component_classes : Component.class)
      shortest_component_list = shortest_component_list_for(*component_classes)
      return if shortest_component_list.nil?

      shortest_component_list.stream do |component|
        entity_id = component.id

        query_set = [] of Fast::ECS::Component

        component_classes.each do |component_class|
          another_component = get_component(component_class, entity_id)
          break if another_component.nil? # i.e. fails the 'AND query'

          query_set.push(another_component)
        end

        yield query_set if query_set.size == component_classes.size
      end
    end

    private def update_system(system : System)
      system.update
    end

    private def reclaim_entity_id_if_free(entity_id : Int32)
      reclaim_entity_id(entity_id) if get_components(entity_id).empty?
    end

    private def reclaim_entity_id(entity_id)
      @entity_id_pool.reclaim_id(entity_id)
    end

    private def debug_log(message)
      puts message if @debug
    end

    private def shortest_component_list_for(*component_classes : Component.class)
      shortest_component_list_index = 0

      shortest_component_list = @component_lists[
        component_classes[shortest_component_list_index].to_s
      ]?

      return if shortest_component_list.nil?

      component_classes.each_with_index do |component_class, index|
        next_shortest_component_list = @component_lists[component_class.to_s]?
        next unless next_shortest_component_list
        next unless next_shortest_component_list.size < shortest_component_list.size

        shortest_component_list = next_shortest_component_list
        shortest_component_list_index = index
      end

      shortest_component_list
    end
  end
end