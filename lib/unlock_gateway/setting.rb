module UnlockGateway
  class Setting

    attr_accessor :key, :title, :description

    def initialize(key, title, description)
      self.key = key
      self.title = title
      self.description = description
    end

  end
end
