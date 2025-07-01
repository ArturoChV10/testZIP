# app/models/cliente.rb
class Cliente
  attr_accessor :nombre, :telefono
  attr_reader :id

  @@clientes = []
  @@contador = 0
  @@archivo = Rails.root.join('public', 'clientes.txt')

  def initialize(nombre, telefono)
    @@contador += 1
    @id = @@contador
    self.nombre = nombre
    self.telefono = telefono
    @@clientes << self
    self.class.guardar_clientes
  end

  # Validaciones
  def nombre=(nombre)
    if nombre.is_a?(String) && !nombre.empty?
      @nombre = nombre
    else
      raise ArgumentError, "Nombre debe ser un string no vacío"
    end
  end

  def telefono=(telefono)
    telefono_str = telefono.to_s
    if telefono_str.match?(/^\d{8}$/) # Validar que sean exactamente 8 dígitos
      @telefono = telefono_str
    else
      raise ArgumentError, "Teléfono debe ser un número de 8 dígitos"
    end
  end

  # Métodos de clase
  class << self
    def todos
      @@clientes
    end

    def cargar_clientes
      return unless File.exist?(@@archivo)
      
      @@clientes.clear
      File.readlines(@@archivo).each do |linea|
        datos = linea.strip.split(',')
        Cliente.new(datos[1], datos[2]) if datos.size == 3
      end
    end

    def guardar_clientes
      File.open(@@archivo, 'w') do |file|
        @@clientes.each do |cliente|
          file.puts "#{cliente.id},#{cliente.nombre},#{cliente.telefono}"
        end
      end
    end

    def buscar_por_id(id)
      @@clientes.find { |c| c.id == id }
    end

    def actualizar(id, nuevos_datos)
      cliente = buscar_por_id(id)
      return false unless cliente

      cliente.nombre = nuevos_datos[:nombre] if nuevos_datos[:nombre]
      cliente.telefono = nuevos_datos[:telefono] if nuevos_datos[:telefono]
    
      guardar_clientes
      cliente
    end
  end

  def eliminar
    @@clientes.delete(self)
    self.class.guardar_clientes
  end

  def to_s
    "ID: #{id} | Cliente: #{nombre} | Teléfono: #{telefono}"
  end
end

# Cargar clientes al iniciar
Cliente.cargar_clientes