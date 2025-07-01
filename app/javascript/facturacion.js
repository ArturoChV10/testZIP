// app/javascript/facturacion.js
document.addEventListener('DOMContentLoaded', function() {
  let productosSeleccionados = [];
  
  // Función para actualizar el resumen
  const actualizarResumen = () => {
    const resumen = document.getElementById('resumen-factura');
    const totalElement = document.getElementById('total-factura');
    const btnGenerar = document.getElementById('generar-factura');
    
    if (productosSeleccionados.length === 0) {
      resumen.innerHTML = '<p>No hay productos agregados</p>';
      totalElement.innerHTML = '<strong>Total: $0.00</strong>';
      btnGenerar.disabled = true;
      return;
    }
    
    let html = `
      <table class="tabla-resumen">
        <thead>
          <tr>
            <th>Producto</th>
            <th>Cantidad</th>
            <th>Precio Unitario</th>
            <th>Subtotal</th>
          </tr>
        </thead>
        <tbody>
    `;
    
    let total = 0;
    
    productosSeleccionados.forEach(item => {
      const subtotal = item.precio * item.cantidad;
      total += subtotal;
      
      html += `
        <tr>
          <td>${item.nombre}</td>
          <td>${item.cantidad}</td>
          <td>$${item.precio.toFixed(2)}</td>
          <td>$${subtotal.toFixed(2)}</td>
        </tr>
      `;
    });
    
    html += `</tbody></table>`;
    resumen.innerHTML = html;
    totalElement.innerHTML = `<strong>Total: $${total.toFixed(2)}</strong>`;
    btnGenerar.disabled = false;
  };
  
  // Evento para agregar productos
  document.querySelectorAll('.btn-agregar').forEach(btn => {
    btn.addEventListener('click', function() {
      const fila = this.closest('tr');
      const productoId = fila.dataset.productoId;
      const nombre = fila.querySelector('td:first-child').textContent;
      const precio = parseFloat(fila.querySelector('td:nth-child(2)').textContent.replace('$', ''));
      const stock = parseInt(fila.dataset.stock);
      const inputCantidad = fila.querySelector('.cantidad');
      let cantidad = parseInt(inputCantidad.value);
      
      // Validación
      cantidad = isNaN(cantidad) ? 0 : Math.max(0, cantidad);
      cantidad = Math.min(cantidad, stock);
      
      if (cantidad <= 0) {
        // Eliminar si existe
        productosSeleccionados = productosSeleccionados.filter(p => p.id !== productoId);
        inputCantidad.value = 0;
      } else {
        // Actualizar o agregar
        const index = productosSeleccionados.findIndex(p => p.id === productoId);
        
        if (index !== -1) {
          productosSeleccionados[index].cantidad = cantidad;
        } else {
          productosSeleccionados.push({
            id: productoId,
            nombre: nombre,
            precio: precio,
            cantidad: cantidad
          });
        }
      }
      
      actualizarResumen();
    });
  });
  
  // Evento para generar factura
document.getElementById('generar-factura')?.addEventListener('click', async () => {
  try {
    // Validar IDs y cantidades numéricas
    const productosValidados = productosSeleccionados.map(p => {
      const id = Number(p.id);
      const cantidad = Number(p.cantidad);
      
      if (isNaN(id) || isNaN(cantidad)) {
        throw new Error(`Datos inválidos para ${p.nombre}`);
      }
      
      return {
        producto_id: id,
        cantidad: cantidad
      };
    });

    const payload = {
      factura: {
        cliente_id: Number(document.getElementById('cliente_id').value),
        productos_attributes: productosValidados
      }
    };

    const response = await fetch('/crear_factura', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify(payload)
    });

    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.error || 'Error del servidor');
    }

    const data = await response.json();
    window.open(`/factura_pdf/${data.factura_id}.pdf`, '_blank');
    
  } catch (error) {
    console.error('Error al facturar:', error);
    alert(`Error: ${error.message}`);
  }
});
  // ==============================================
});