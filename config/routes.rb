Rails.application.routes.draw do
  # Rutas existentes (productos y clientes)
  root 'saludos#menu'
  get 'productos', to: 'saludos#index'
  get 'clientes', to: 'saludos#clientes'
  
  # Rutas para facturación
  get 'facturar', to: 'saludos#facturar', as: 'facturar'
  post 'crear_factura', to: 'saludos#crear_factura'
  get 'factura_pdf/:id', to: 'saludos#factura_pdf', defaults: { format: 'pdf' }
  
  # Rutas CRUD para productos y clientes (ya existentes)
  post 'crear_producto', to: 'saludos#crear_producto'
  put 'actualizar_producto/:id', to: 'saludos#actualizar_producto'
  delete 'eliminar_producto/:id', to: 'saludos#eliminar_producto'
  post 'crear_cliente', to: 'saludos#crear_cliente'
  put 'actualizar_cliente/:id', to: 'saludos#actualizar_cliente'
  delete 'eliminar_cliente/:id', to: 'saludos#eliminar_cliente'
end