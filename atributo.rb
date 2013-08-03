class Atributo
  attr_accessor :nombre, :instancias

  def initialize(nombre, instancias = [])
    @nombre, @instancias = nombre, instancias
  end
end