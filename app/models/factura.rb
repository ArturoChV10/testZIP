class Factura
  attr_accessor :cliente_id, :productos, :fecha
  attr_reader :id

  @@facturas = []
  @@contador = 0
  @@archivo = Rails.root.join('public', 'facturas.txt')

  def initialize(cliente_id, productos = [])
    @@contador += 1
    @id = @@contador
    @cliente_id = cliente_id
    @productos = productos
    @fecha = Time.now
    @@facturas << self
    self.class.guardar_facturas
  end

  def cliente
    Cliente.buscar_por_id(@cliente_id)
  end

  def total
    productos.sum { |p| p[:precio] * p[:cantidad] }
  end

  class << self
    def todas
      @@facturas
    end

    def cargar_facturas
      return unless File.exist?(@@archivo)
      @@facturas.clear
      File.readlines(@@archivo).each do |linea|
        datos = JSON.parse(linea.strip)
        productos = datos["productos"].map do |p|
          { id: p["id"], nombre: p["nombre"], precio: p["precio"], cantidad: p["cantidad"] }
        end
        factura = Factura.new(datos["cliente_id"].to_i, productos)
        factura.instance_variable_set(:@id, datos["id"].to_i)
      end
    end

    def guardar_facturas
      File.open(@@archivo, 'w') do |file|
        @@facturas.each do |factura|
          factura_data = {
            id: factura.id,
            cliente_id: factura.cliente_id,
            productos: factura.productos,
            fecha: factura.fecha
          }
          file.puts factura_data.to_json
        end
      end
    end

    def buscar_por_id(id)
      @@facturas.find { |f| f.id == id }
    end
  end
end