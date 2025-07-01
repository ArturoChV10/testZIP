class Saludo
  attr_accessor :nombre, :precio, :cantidad
  attr_reader :id

  @@contador = 0

  def initialize(nombre, precio, cantidad)
    @@contador += 1
    @id = @@contador
    self.nombre = nombre
    self.precio = precio
    self.cantidad = cantidad
  end

  # Validaciones al asignar valores
  def nombre=(nombre)
    if nombre.is_a?(String)
      @nombre = nombre
    else
      raise ArgumentError, "El nombre debe ser un String"
    end
  end

  def precio=(precio)
    if precio.is_a?(Numeric)
      @precio = precio
    else
      raise ArgumentError, "El precio debe ser un valor numérico"
    end
  end

  def cantidad=(cantidad)
    if cantidad.is_a?(Integer)
      @cantidad = cantidad
    else
      raise ArgumentError, "La cantidad debe ser un número entero (Integer)"
    end
  end

  # Métodos de negocio
  def agregarCantidad(cant)
    if cant.is_a?(Integer)
      @cantidad += cant
      true
    else
      raise ArgumentError, "La cantidad a agregar debe ser un número entero (Integer)"
    end
  end

  def restarCantidad(cant)
    if cant.is_a?(Integer)
      if @cantidad >= cant
        @cantidad -= cant
        true
      else
        puts "Inventario insuficiente"
        false
      end
    else
      raise ArgumentError, "La cantidad a eliminar debe ser un número entero (Integer)"
    end
  end

  def self.saludarRuby(nombre, precio, cantidad)
    # 1. Especifica una ruta absoluta para el archivo
    archivo = Rails.root.join('public', 'productos.txt').to_s
  
    # 2. Asegura que el directorio existe
    FileUtils.mkdir_p(File.dirname(archivo)) unless Dir.exist?(File.dirname(archivo))
  
    # 3. Modo de escritura mejorado
    File.open(archivo, 'a+') do |file|
      file.sync = true # Desactiva buffering
    
      # 4. Lee las líneas existentes
      lineas = file.readlines.map(&:strip)
      ultimo_id = lineas.empty? ? 0 : lineas.last.split(',').first.to_i
    
      # 5. Genera el nuevo ID
      nuevo_id = ultimo_id + 1
    
      # 6. Escribe el nuevo registro
      file.puts "#{nuevo_id},#{nombre},#{precio},#{cantidad}"
    end

    # 7. Retorna el mensaje
    "Hola #{nombre}, mi precio es #{precio} y tengo #{cantidad}"
  end
end