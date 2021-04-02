module Fast::ECS
  class EntityIdPool
    def initialize(@last_used_entity_id = -1,
                   @reclaimed_entity_id_pool = [] of Int32,
                   @reclaimed_entity_id_pool_size = 0)
    end

    def reclaim_id(entity_id : Int32)
      if @reclaimed_entity_id_pool.size == @reclaimed_entity_id_pool_size
        @reclaimed_entity_id_pool.push(entity_id) # grow max array size
      else
        @reclaimed_entity_id_pool[@reclaimed_entity_id_pool_size] = entity_id # re-use existing array space
      end

      @reclaimed_entity_id_pool_size += 1
    end

    def get_id
      index = @reclaimed_entity_id_pool_size - 1

      if 0 <= index
        @reclaimed_entity_id_pool_size -= 1
        return @reclaimed_entity_id_pool[index]
      end

      @last_used_entity_id += 1
    end

    def clear
      old_reclaimed_entity_id_pool_size = @reclaimed_entity_id_pool_size
      @reclaimed_entity_id_pool_size = 0
      @last_used_entity_id = -1
      old_reclaimed_entity_id_pool_size
    end

    def size
      @reclaimed_entity_id_pool_size
    end

    def state
      {
        :last_used_entity_id           => @last_used_entity_id,
        :reclaimed_entity_id_pool      => @reclaimed_entity_id_pool,
        :reclaimed_entity_id_pool_size => @reclaimed_entity_id_pool_size,
      }
    end
  end
end
