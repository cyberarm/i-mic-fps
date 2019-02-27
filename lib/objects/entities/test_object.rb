class IMICFPS
  class TestObject < Entity
    def setup
      bind_model("base", "war_factory")
      @backface_culling = false
    end
  end
end
