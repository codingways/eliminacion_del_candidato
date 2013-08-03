require_relative 'atributo'
require_relative 'ejemplo'
require_relative 'hipotesis'
require 'benchmark'

class EliminacionDelCandidato
  attr_accessor :atributos, :ejemplos

  def initialize(atributos, ejemplos)
    @atributos, @ejemplos = atributos, ejemplos
  end

  def run
    espacio_versiones = []
    generales = [Hipotesis.new(["?","?","?","?","?","?"])]
    especificas = [Hipotesis.new(["0","0","0","0","0","0"])]

    @atributos.each do |atributo|
      atributo.instancias.push "?"
    end
    
    # Construir espacio de versiones (Todas las combinaciones entre instancias de atributos)
    @atributos[0].instancias.each do |attr1|
      @atributos[1].instancias.each do |attr2|
        @atributos[2].instancias.each do |attr3|
          @atributos[3].instancias.each do |attr4|
            @atributos[4].instancias.each do |attr5|
              @atributos[5].instancias.each do |attr6|
                espacio_versiones << Hipotesis.new([attr1, attr2, attr3, attr4, attr5, attr6])
              end
            end
          end  
        end
      end
    end

    @ejemplos.each_with_index do |d, i|
      if d.clasificacion == true
        generales.select! { |hipotesis| hipotesis.consistente(d) } # Eliminar de G los que no sean consistentes con d
        especificas.select { |hipotesis| !hipotesis.consistente(d) }.each do |s| # Eliminar de S los que no sean consistentes con d
          especificas.delete(s)
          espacio_versiones.each do |h|
            consistente = true
            0.upto(i) do |j|
              if !h.consistente(@ejemplos[j])
                consistente = false
                break
              end            
            end

            if consistente and generales.select { |hipotesis| hipotesis.mas_general(h)}.any?
              especificas << h
            end
          end
          especificidad = especificas.map { |s| s.generalidad }.min 
          especificas.select! { |s| s.generalidad == especificidad }
        end
      else
        especificas.select! { |hipotesis| hipotesis.consistente(d) } # Eliminar de S los que no sean consistentes con d
        generales.select { |hipotesis| !hipotesis.consistente(d) }.each do |g| # Eliminar de G los que no sean consistentes con d
          generales.delete(g)
          espacio_versiones.each do |h|
            consistente = true
            0.upto(i) do |j|
              if !h.consistente(@ejemplos[j])
                consistente = false
                break
              end            
            end

            if consistente and especificas.select { |hipotesis| hipotesis.mas_especifico(h)}.any?
              generales << h
            end
          end
          generalidad = generales.map { |g| g.generalidad }.max
          generales.select! { |g| g.generalidad == generalidad }
        end 
      end     
    end

    [especificas,generales]
  end
end

cielo = Atributo.new('cielo',["soleado","nublado","lluvioso"])
temp_aire = Atributo.new('temp_aire',["templada","fria"])
humedad = Atributo.new('humedad',["normal","alta"])
viento = Atributo.new('viento',["fuerte","debil"])
temp_agua = Atributo.new('temp_agua',["templada","fria"])
pronostico = Atributo.new('pronostico',["igual","cambia"])

ej1 = Ejemplo.new(["soleado","templada","normal","fuerte","templada","igual"], true)
ej2 = Ejemplo.new(["soleado","templada","alta","fuerte","templada","igual"], true)
ej3 = Ejemplo.new(["lluvioso","fria","alta","fuerte","templada","cambia"], false)
ej4 = Ejemplo.new(["soleado","templada","alta","fuerte","fria","cambia"], true)

edc = EliminacionDelCandidato.new([cielo,temp_aire,humedad,viento,temp_agua,pronostico], [ej1,ej2,ej3,ej4])
res = nil
Benchmark.bm do |b|
  b.report("Eliminacion del candidato:") { res = edc.run }
end
puts "Especificas\n#{res[0]}\n\nGenerales#{res[1]}"