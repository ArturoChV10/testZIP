class SaludosController < ApplicationController
  def menu
    # No implementacion, es para el menu
  end

  def index
    Producto.cargar_productos unless Producto.todos.any?
    @productos = Producto.todos
  end

  def crear_producto
    begin
      producto = Producto.new(
        params[:nombre],
        params[:precio],
        params[:cantidad]
      )
      
      render json: { 
        mensaje: "Producto creado: #{producto.nombre}",
        producto: {
          id: producto.id,
          nombre: producto.nombre,
          precio: producto.precio,
          cantidad: producto.cantidad
        }
      }
    rescue ArgumentError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  def actualizar_producto
    producto = Producto.actualizar(
      params[:id].to_i,
      nombre: params[:nombre],
      precio: params[:precio],
      cantidad: params[:cantidad]
    )

    if producto
      render json: { 
        mensaje: "Producto actualizado",
        producto: {
          id: producto.id,
          nombre: producto.nombre,
          precio: producto.precio,
          cantidad: producto.cantidad
        }
      }
    else
      render json: { error: "Producto no encontrado" }, status: :not_found
    end
  end

  def eliminar_producto
    producto = Producto.buscar_por_id(params[:id].to_i)
    
    if producto
      producto.eliminar
      render json: { mensaje: "Producto eliminado" }
    else
      render json: { error: "Producto no encontrado" }, status: :not_found
    end
  end

  def clientes
    Cliente.cargar_clientes unless Cliente.todos.any?
    @clientes = Cliente.todos
  end

  def crear_cliente
    begin
      cliente = Cliente.new(
        params[:nombre],
        params[:telefono]
      )
      
      render json: { 
        mensaje: "Cliente creado: #{cliente.nombre}",
        cliente: {
          id: cliente.id,
          nombre: cliente.nombre,
          telefono: cliente.telefono
        }
      }
    rescue ArgumentError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  def actualizar_cliente
    cliente = Cliente.actualizar(
      params[:id].to_i,
      nombre: params[:nombre],
      telefono: params[:telefono]
    )

    if cliente
      render json: { 
        mensaje: "Cliente actualizado",
        cliente: {
          id: cliente.id,
          nombre: cliente.nombre,
          telefono: cliente.telefono
        }
      }
    else
      render json: { error: "Cliente no encontrado" }, status: :not_found
    end
  end

  def eliminar_cliente
    cliente = Cliente.buscar_por_id(params[:id].to_i)
    
    if cliente
      cliente.eliminar
      render json: { mensaje: "Cliente eliminado" }
    else
      render json: { error: "Cliente no encontrado" }, status: :not_found
    end
  end

  def facturar
    @clientes = Cliente.todos
    @productos = Producto.todos
  end

def crear_factura
  begin
    # Limpieza manual de parámetros
    factura_params = {
      cliente_id: params.dig(:factura, :cliente_id).to_i,
      productos_attributes: Array(params.dig(:factura, :productos_attributes)).map { |p|
        {
          producto_id: p[:producto_id] || p["producto_id"] || 0,
          cantidad: p[:cantidad] || p["cantidad"] || 0
        }.transform_values(&:to_i)
      }
    }

    # Validaciones estrictas
    raise ArgumentError, "ID de cliente inválido" unless factura_params[:cliente_id] > 0
    raise ArgumentError, "No hay productos" if factura_params[:productos_attributes].empty?
    
    factura_params[:productos_attributes].each do |p|
      raise ArgumentError, "ID de producto inválido" unless p[:producto_id] > 0
      raise ArgumentError, "Cantidad inválida" unless p[:cantidad] > 0
    end

    # Procesamiento seguro
    productos = factura_params[:productos_attributes].map do |p|
      producto = Producto.buscar_por_id(p[:producto_id])
      raise ArgumentError, "Producto no encontrado" unless producto
      
      if producto.cantidad < p[:cantidad]
        raise ArgumentError, "Stock insuficiente de #{producto.nombre}"
      end

      {
        id: producto.id,
        nombre: producto.nombre,
        precio: producto.precio,
        cantidad: p[:cantidad]
      }
    end

    factura = Factura.new(factura_params[:cliente_id], productos)
    render json: { factura_id: factura.id }

  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end
end

def factura_pdf
  @factura = Factura.buscar_por_id(params[:id])
  
  respond_to do |format|
    format.pdf do
      pdf = Prawn::Document.new(page_size: 'A4', page_layout: :portrait) do
        text "Factura ##{@factura.id}", size: 18, style: :bold, align: :center
        move_down 20
        
        # Información del cliente
        text "Cliente: #{@factura.cliente.nombre}"
        text "Fecha: #{@factura.fecha.strftime('%d/%m/%Y')}"
        move_down 20
        
        # Tabla de productos
        items = [["Producto", "Cantidad", "Precio", "Subtotal"]]
        @factura.productos.each do |p|
          items << [p[:nombre], p[:cantidad], "$#{p[:precio]}", "$#{p[:precio] * p[:cantidad]}"]
        end
        items << ["", "", "TOTAL:", "$#{@factura.total}"]
        
        table(items, width: bounds.width) do
          row(0).font_style = :bold
          row(-1).font_style = :bold
        end
      end
      
      send_data pdf.render,
                filename: "factura_#{@factura.id}.pdf",
                type: 'application/pdf',
                disposition: :inline
    end
  end
end

end