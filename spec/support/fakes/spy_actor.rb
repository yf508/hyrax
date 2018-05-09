# frozen_string_literal: true
class SpyActor
  attr_accessor :created, :updated, :destroyed

  def create(_env)
    self.created = true
  end

  def update(_env)
    self.updated = true
  end

  def destroy(_env)
    self.destroyed = true
  end
end
