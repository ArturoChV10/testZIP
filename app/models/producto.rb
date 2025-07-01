class Producto
  attr_accessor :nombre, :precio, :cantidad
  attr_reader :id

  @@productos = []
  @@contador = 0
  @@archivo = Rails.root.join('public', 'productos.txt')

  def initialize(nombre, precio, cantidad)
    @@contador += 1
    @id = @@contador
    self.nombre = nombre
    self.precio = precio
    self.cantidad = cantidad
    @@productos << self
    self.class.guardar_productos
  end

  # Validaciones
  def nombre=(nombre)
    if nombre.is_a?(String) && !nombre.empty?
      @nombre = nombre
    else
      raise ArgumentError, "Nombre debe ser un string no vacío"
    end
  end

  def precio=(precio)
    precio_num = precio.is_a?(String) ? Float(precio) : precio
    if precio_num.is_a?(Numeric) && precio_num >= 0
      @precio = precio_num
    else
      raise ArgumentError, "Precio debe ser un número positivo"
    end
  end

  def cantidad=(cantidad)
    cantidad_int = cantidad.is_a?(String) ? Integer(cantidad) : cantidad
    if cantidad_int.is_a?(Integer) && cantidad_int >= 0
      @cantidad = cantidad_int
    else
      raise ArgumentError, "Cantidad debe ser un entero positivo"
    end
  end

  # Métodos de clase
  class << self
    def todos
      @@productos
    end

    def cargar_productos
      return unless File.exist?(@@archivo)
      
      @@productos.clear
      File.readlines(@@archivo).each do |linea|
        datos = linea.strip.split(',')
        Producto.new(datos[1], datos[2], datos[3]) if datos.size == 4
      end
    end

    def guardar_productos
      File.open(@@archivo, 'w') do |file|
        @@productos.each do |producto|
          file.puts "#{producto.id},#{producto.nombre},#{producto.precio},#{producto.cantidad}"
        end
      end
    end

    def buscar_por_id(id)
      @@productos.find { |p| p.id == id }
    end
  end

  def self.actualizar(id, nuevos_datos)
    producto = buscar_por_id(id)
    return false unless producto

    producto.nombre = nuevos_datos[:nombre] if nuevos_datos[:nombre]
    producto.precio = nuevos_datos[:precio] if nuevos_datos[:precio]
    producto.cantidad = nuevos_datos[:cantidad] if nuevos_datos[:cantidad]
  
    guardar_productos
    producto
  end

  def eliminar
    @@productos.delete(self)
    self.class.guardar_productos
  end

  def to_s
    "ID: #{id} | Producto: #{nombre} | Precio: $#{precio} | Cantidad: #{cantidad}"
  end
end

# Cargar productos al iniciar
Producto.cargar_productos