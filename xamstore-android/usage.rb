class Usage < Relation
  def initialize(parent, child) #TODO: use better names
    @parent = parent
    @children = [child]
  end
end