module Fast::ECS
  abstract class System
    getter :engine
    delegate delta_time, to: @engine.not_nil!

    def add_engine(engine : Engine)
      @engine = engine
    end

    # init stuff, engine should run this when system right after system is added
    abstract def start

    # NOTE: called once per tick. DeltaTime can be extracted from the engine reference
    abstract def update

    # clean up before system shutdown, engine should call this before removing system
    abstract def destroy
  end
end
