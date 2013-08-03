class Hipotesis
  attr_accessor :valores

  def initialize(valores)
    @valores = valores
  end

  def consistente(ejemplo)
    if ejemplo.clasificacion == true and acepta(ejemplo)
      return true
    elsif ejemplo.clasificacion == false and !acepta(ejemplo)
      return true
    end
    return false
  end

  def mas_general(hipotesis)
    if generalidad >= hipotesis.generalidad
      return true
    end
    return false
  end

  def generalidad
    generalidad = 0
    @valores.each do |valor|
      generalidad += 2 if valor == '?'
      generalidad += 1 if valor != '0' and valor != '?'
    end
    generalidad
  end

  def mas_especifico(hipotesis)
    if generalidad <= hipotesis.generalidad
      return true
    end
    return false
  end

  protected

  def acepta(ejemplo)
    @valores.each_with_index do |valor, i|
      if valor != '?' and valor != ejemplo.valores[i]
        return false
      end
    end
    return true
  end
end