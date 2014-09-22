class Relation
  attr_reader :parent, :children

  def add_relation
    FragmentLoader.add_relation(self)
  end

  def valid?
    true
  end
end