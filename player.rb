class Player

attr_accessor :id
attr_reader :name
attr_reader :email

def initialize(id, name, email)
  @id = id
  @name = name
  @email = email
end

end
