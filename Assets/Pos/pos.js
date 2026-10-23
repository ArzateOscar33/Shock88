/* SHOCK 88 | POS visual demo | No backend calls, payments, or writes. */
(() => {
 'use strict';
 const $ = id => document.getElementById(id);
 const data = JSON.parse($('pos-data')?.textContent || '{}');
 const products = data.productos || [];
 const customers = [...(data.clientes || [])];
 const coupons = data.cupones || [];
 const variants = new Map();
 for (const p of products) for (const v of p.variantes) variants.set(Number(v.id), {...v, name:p.nombre, productId:p.id, image:p.imagen, category:p.categoria});
 const money = n => new Intl.NumberFormat('es-MX', {style:'currency',currency:'MXN',minimumFractionDigits:2,maximumFractionDigits:2}).format(Number(n) || 0);
 const escapeHtml = v => String(v ?? '').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
 let cart = new Map(), customer=null, activeCoupon=null, method='EFECTIVO', category='Todas', term='', saleCount=1, cashReceived='', filterTimer;
 let toastTimer;
 const notify=(message)=>{clearTimeout(toastTimer);$('toast').textContent=message;$('toast').classList.add('show');toastTimer=setTimeout(()=>$('toast').classList.remove('show'),3100);};
 const subtotal=()=>[...cart].reduce((sum,[id,qty])=>sum+(variants.get(Number(id))?.precio||0)*qty,0);
 function couponStatus(c) {
   if(!c)return {valid:false,reason:'No hay cupón.'};
   const sub=subtotal();
   if (!cart.size) return {valid:false,reason:'Agrega prendas antes de aplicar el cupón.'};
   if(sub<c.minimo) return {valid:false,reason:`La compra mínima para este cupón es ${money(c.minimo)}.`};
   if(c.soloCliente&&!customer) return {valid:false,reason:'Identifica al cliente para utilizar este cupón.'};
   if(c.clase==='VIP'&&customer?.tipo!=='VIP')return {valid:false,reason:'Este código es exclusivo para clientes VIP.'};
   if(c.clase==='LEALTAD'&&!customer?.recompensa)return {valid:false,reason:'El cliente no tiene un cupón de lealtad disponible.'};
   return {valid:true,reason:`Cupón ${c.codigo} · ${c.porcentaje}% aplicado (demo).`};
 }
 function calculate(){
   const sub=subtotal();
   let pct=0;
   if(activeCoupon && couponStatus(activeCoupon).valid)pct=Number(activeCoupon.porcentaje);
   const discount=Math.round(sub*pct)/100;
   return {sub,discount,total:Math.max(0,sub-discount),pct};
 }
 function getUnitCount(){return [...cart.values()].reduce((a,b)=>a+b,0);}
 function productCard(p,idx) {
   const prices=p.variantes.map(v=>Number(v.precio));
   const stock=p.variantes.reduce((sum,v)=>sum+v.stock,0);
   const chosen=(p.variantes || []).map(v=>`<button type="button" data-add="${v.id}" title="${escapeHtml(v.talla)} · ${escapeHtml(v.sku)} · Stock de muestra: ${v.stock}">${escapeHtml(v.talla)}</button>`).join('');
   const img=p.imagen?`<img loading="lazy" src="${escapeHtml(p.imagen)}" alt="${escapeHtml(p.nombre)}" onerror="this.style.display='none';this.parentElement.querySelector('.fallback-img').hidden=false">`:'';
   return `<article class="product-card" style="animation-delay:${Math.min(idx,8)*35}ms"><div class="product-image">${img}<i class="fa-solid fa-shirt fallback-img" ${p.imagen?'hidden':''}></i><span class="stock-badge">${stock} pzas. · demo</span></div><div class="product-card-body"><span class="product-cat">${escapeHtml(p.categoria)}</span><h3>${escapeHtml(p.nombre)}</h3><div class="price-row"><strong>${money(Math.min(...prices))}</strong><small>${escapeHtml(p.variantes[0]?.color||'')}</small></div><div class="size-picker">${chosen}</div></div></article>`;
 }
 function renderProducts(){
  const q=term.trim().toLowerCase();
  const visible=products.filter(p=>(category==='Todas'||p.categoria===category) && (!q||`${p.nombre} ${p.categoria} ${p.variantes.map(v=>`${v.sku} ${v.talla}`).join(' ')}`.toLowerCase().includes(q)));
  $('catalog-results').textContent=`${visible.length} PRODUCTO${visible.length===1?'':'S'}`;
  $('product-grid').innerHTML=visible.length?visible.map(productCard).join(''):'<div class="no-results"><i class="fa-solid fa-magnifying-glass"></i><p>No se encontraron productos.</p></div>';
 }
 function syncCoupon(){
   if(activeCoupon && !couponStatus(activeCoupon).valid){
     const reason=couponStatus(activeCoupon).reason;
     activeCoupon=null;
     $('coupon-code').value='';
     $('coupon-feedback').textContent=`Cupón retirado: ${reason}`;
     $('coupon-feedback').classList.add('error');
   }
 }
 function renderCart(){
   syncCoupon();
   const rows=[...cart].map(([id,qty])=>{
      const v=variants.get(Number(id)); if(!v)return '';
      return `<div class="ticket-line"><div class="line-product"><div class="line-thumb">${v.image?`<img loading="lazy" src="${escapeHtml(v.image)}" alt="">`:''}</div><div class="line-desc"><strong>${escapeHtml(v.name)}</strong><small>${escapeHtml(v.sku)} · ${escapeHtml(v.talla)} / ${escapeHtml(v.color)}</small><button type="button" class="remove-line" data-remove="${id}"><i class="fa-solid fa-trash-can"></i> Quitar</button></div></div><div class="cell-price">${money(v.precio)}</div><div class="qty-controls"><button type="button" data-minus="${id}" aria-label="Quitar una unidad">−</button><span>${qty}</span><button type="button" data-plus="${id}" aria-label="Agregar una unidad">+</button></div><div class="cell-total">${money(v.precio*qty)}</div></div>`;
   });
   $('cart-list').innerHTML=rows.length?rows.join(''):'<div class="cart-placeholder"><span class="empty-circle"><i class="fa-solid fa-bag-shopping"></i></span><strong>EL TICKET ESTÁ VACÍO</strong><p>Selecciona una prenda del catálogo para iniciar.</p></div>';
   $('ticket-count').textContent=`(${getUnitCount()})`;
   const {sub,discount,total,pct}=calculate();
   $('subtotal').textContent=money(sub);
   $('discount').textContent='−'+money(discount);
   $('discount-label').textContent=pct?`(${pct}% · ${activeCoupon.codigo})`:'';
   $('grand-total').textContent=money(total);
   $('checkout-total').textContent=money(total);
   $('checkout').disabled=!cart.size;
   updateCash();
 }
 function changeQty(id,by){
   const v=variants.get(Number(id)); if(!v)return;
   const qty=cart.get(Number(id))||0;
   const next=qty+by;
   if(next>v.stock){notify(`Existencia de muestra: ${v.stock} pieza(s) para ${v.sku}.`);return;}
   if(next<=0)cart.delete(Number(id));else cart.set(Number(id),next);
   renderCart();
 }
 function addVariant(id){
  if(!variants.has(Number(id)))return;
  changeQty(Number(id),1);
  const v=variants.get(Number(id));notify(`${v.name} · ${v.talla} agregada al ticket (demo).`);
 }
 function updateCash(){
   if (method!=='EFECTIVO')return;
   const total=calculate().total;
   const received=Number($('cash-received').value||0);
   $('change-due').textContent=money(Math.max(0,received-total));
   $('change-due').style.color=received<total?'#b48b43':'#129f85';
 }
 function updateCustomer(){
   $('customer-name').textContent=customer?.nombre||'Público general';
   $('customer-detail').textContent=customer?`${customer.telefono||'Sin teléfono'} · ID demo ${customer.id}`:'Venta sin cliente identificado';
   $('customer-avatar').innerHTML=customer?`<strong>${escapeHtml(customer.nombre.charAt(0).toUpperCase())}</strong>`:'<i class="fa-regular fa-user"></i>';
   $('loyalty-box').hidden=!customer;
   if(customer){
     $('loyalty-count').textContent=`${Math.min(10,customer.compras)} / 10`;
     $('loyalty-progress').style.width=Math.min(100,customer.compras*10)+'%';
     $('loyalty-detail').textContent=customer.recompensa?'Cupón del 10% disponible (demostración).':`Le faltan ${Math.max(0,10-customer.compras)} ventas pagadas para su cupón, según el SQL actual.`;
   }
   syncCoupon();renderCart();
 }
 function chooseCustomer(id){customer=customers.find(x=>x.id===Number(id))||null;updateCustomer();closeModal();notify(customer?`${customer.nombre} vinculado(a) al ticket de demostración.`:'Venta configurada como público general.');}
 function renderCustomers(){
  const q=$('customer-search').value.trim().toLowerCase();
  const found=customers.filter(c=>`${c.nombre} ${c.telefono} ${c.email||''}`.toLowerCase().includes(q));
  $('customer-results').innerHTML=found.length?found.map(c=>`<button type="button" class="customer-result" data-customer="${c.id}"><span class="result-avatar">${escapeHtml(c.nombre.charAt(0))}</span><span class="result-user"><strong>${escapeHtml(c.nombre)}</strong><small>${escapeHtml(c.telefono||'Sin teléfono')} · ${escapeHtml(c.email||'Sin correo')}</small></span><span class="result-reward">${c.recompensa?'<i class="fa-solid fa-ticket"></i> CUPÓN DISPONIBLE':`${c.compras}/10 ventas`}</span></button>`).join(''):'<p class="info-paragraph">No encontramos clientes. Puedes crear un registro de demostración.</p>';
 }
 let currentModal=null;
 function openModal(name){
   const element=$(`${name}-modal`);
   if(!element)return;
   if(currentModal)currentModal.hidden=true;
   $('overlay').hidden=false;
   element.hidden=false;
   currentModal=element;
   document.body.style.overflow='hidden';
   if(name==='customer') {renderCustomers();setTimeout(()=>$('customer-search').focus(),30);}
 }
 function closeModal(){if(currentModal)currentModal.hidden=true;currentModal=null;$('overlay').hidden=true;document.body.style.overflow='';}
 function info(title,html){$('info-modal-title').textContent=title;$('info-modal-body').innerHTML=html;openModal('info');}
 function newSale(){cart.clear();activeCoupon=null;customer=null;method='EFECTIVO';$('cash-received').value='';$('coupon-code').value='';$('coupon-feedback').textContent='';$('coupon-feedback').classList.remove('error');saleCount++;$('sale-folio').textContent='S88-DEM-'+String(saleCount).padStart(4,'0');document.querySelector('[data-payment="EFECTIVO"]').click();updateCustomer();closeModal();}
 function simulateSale(){
   const t=calculate(),paid=Number($('cash-received').value);
   if(!cart.size){notify('Agrega al menos una prenda.');return;}
   if(method==='EFECTIVO' && (!Number.isFinite(paid)||paid<t.total)){notify(`Falta efectivo. Total a cobrar: ${money(t.total)}.`);$('cash-received').focus();return;}
   const rows=[...cart].map(([id,qty])=>{const v=variants.get(Number(id));return `<div class="receipt-row"><span>${qty} × ${escapeHtml(v.name)} (${escapeHtml(v.talla)})</span><b>${money(v.precio*qty)}</b></div>`;}).join('');
   $('receipt-lines').innerHTML=`<div class="receipt-row"><span>Folio de muestra</span><b>${escapeHtml($('sale-folio').textContent)}</b></div><div class="receipt-row"><span>Cliente</span><b>${escapeHtml(customer?.nombre||'Público general')}</b></div><div class="receipt-row"><span>Pago simulado</span><b>${escapeHtml(method)}</b></div>${rows}<div class="receipt-row"><span>Subtotal</span><b>${money(t.sub)}</b></div><div class="receipt-row"><span>Descuento ${activeCoupon?'('+escapeHtml(activeCoupon.codigo)+')':''}</span><b>−${money(t.discount)}</b></div><div class="receipt-row receipt-total"><span>TOTAL</span><b>${money(t.total)}</b></div>${method==='EFECTIVO'?`<div class="receipt-row"><span>Recibido (simulado)</span><b>${money(paid)}</b></div><div class="receipt-row"><span>Cambio (simulado)</span><b>${money(paid-t.total)}</b></div>`:''}`;
   openModal('sale');
 }
 $('product-grid').addEventListener('click',e=>{const btn=e.target.closest('[data-add]');if(btn)addVariant(btn.dataset.add);});
 $('cart-list').addEventListener('click',e=>{const btn=e.target.closest('button');if(!btn)return;if(btn.dataset.remove){cart.delete(Number(btn.dataset.remove));renderCart();}if(btn.dataset.minus)changeQty(btn.dataset.minus,-1);if(btn.dataset.plus)changeQty(btn.dataset.plus,1);});
 $('product-search').addEventListener('input',e=>{term=e.target.value;renderProducts();});
 document.querySelectorAll('.category-chip').forEach(b=>b.addEventListener('click',()=>{category=b.dataset.category;document.querySelectorAll('.category-chip').forEach(btn=>btn.classList.toggle('active',btn===b));renderProducts();}));
 $('barcode-focus').addEventListener('click',()=>{$('product-search').focus();notify('Escribe o escanea un SKU en el buscador.');});
 document.addEventListener('keydown',e=>{if((e.ctrlKey||e.metaKey)&&e.key.toLowerCase()==='k'){e.preventDefault();$('product-search').focus();$('product-search').select();}if(e.key==='Escape'){closeModal();hideSidebar();}});
 $('choose-customer').addEventListener('click',()=>openModal('customer'));
 $('guest-customer').addEventListener('click',()=>chooseCustomer(-1));
 $('customer-search').addEventListener('input',renderCustomers);
 $('customer-results').addEventListener('click',e=>{const b=e.target.closest('[data-customer]');if(b)chooseCustomer(b.dataset.customer);});
 $('new-client').addEventListener('click',()=>{$('new-client-form').hidden=!$('new-client-form').hidden;});
 $('new-client-form').addEventListener('submit',e=>{
   e.preventDefault();const fd=new FormData(e.currentTarget);const name=String(fd.get('nombre')||'').trim();if(name.length<3)return;
   const record={id:900+customers.length,nombre:name,telefono:String(fd.get('telefono')||''),email:String(fd.get('email')||''),compras:0,recompensa:false,tipo:'REGULAR'};
   customers.push(record);e.currentTarget.reset();$('new-client-form').hidden=true;chooseCustomer(record.id);
 });
 $('apply-coupon').addEventListener('click',()=>{
   const code=$('coupon-code').value.trim().toUpperCase();
   if(activeCoupon&&activeCoupon.codigo===code){activeCoupon=null;$('coupon-code').value='';$('coupon-feedback').textContent='Cupón retirado.';$('coupon-feedback').classList.remove('error');renderCart();return;}
   const coupon=coupons.find(c=>c.codigo===code);
   const result=couponStatus(coupon);
   if(!result.valid){$('coupon-feedback').classList.add('error');$('coupon-feedback').textContent=coupon?result.reason:'Cupón no encontrado (demo). Prueba SHOCK10, VIP15 o REWARDS10.';return;}
   activeCoupon=coupon;$('coupon-feedback').classList.remove('error');$('coupon-feedback').textContent=result.reason;renderCart();
 });
 $('coupon-code').addEventListener('keydown',e=>{if(e.key==='Enter'){e.preventDefault();$('apply-coupon').click();}});
 $('discount-help').addEventListener('click',()=>info('REGLAS DE DESCUENTO',`<p class="info-paragraph">En el prototipo puedes probar tres códigos: <b>SHOCK10</b> (10% a partir de $500), <b>VIP15</b> (15% a partir de $1,000 para Andrea) y <b>REWARDS10</b> (10% de lealtad para Andrea).</p><p class="info-paragraph">Solo se admite <b>un cupón por pedido</b>. No hay descuentos acumulables. Los permisos y validaciones definitivas estarán en PHP al conectar MySQL.</p>`));
 document.querySelectorAll('.payment-btn').forEach(b=>b.addEventListener('click',()=>{
   method=b.dataset.payment;
   document.querySelectorAll('.payment-btn').forEach(c=>{c.classList.toggle('active',c===b);c.setAttribute('aria-pressed',String(c===b));});
   $('cash-payment').hidden=method!=='EFECTIVO';$('payment-message').hidden=method==='EFECTIVO';
   $('payment-message').textContent=method==='TARJETA'?'Tarjeta (demo): aquí se integrará la confirmación de la terminal de cobro. No se cobra nada.':'Transferencia (demo): el vendedor deberá verificar el abono antes de confirmar la venta real.';
   updateCash();
 }));
 $('cash-received').addEventListener('input',updateCash);
 $('checkout').addEventListener('click',simulateSale);
 $('new-sale').addEventListener('click',()=>{if(cart.size&&!confirm('¿Descartar la venta de demostración actual y comenzar otra?'))return;newSale();});
 $('start-next-sale').addEventListener('click',newSale);
 document.querySelectorAll('.modal-close').forEach(b=>b.addEventListener('click',closeModal));
 $('overlay').addEventListener('click',closeModal);
 document.querySelectorAll('[data-modal]').forEach(b=>b.addEventListener('click',()=>{
   if(b.dataset.modal==='history')info('VENTAS RECIENTES (DEMO)',`<p class="info-paragraph">Historial ilustrativo. La consulta real se realizará mediante las tablas <b>pedidos</b>, <b>pedido_detalles</b> y <b>pagos</b>.</p><div class="receipt-card"><div class="receipt-row"><span>S88-00421 · Venta física</span><b>$1,248.00</b></div><div class="receipt-row"><span>S88-00420 · Venta física</span><b>$899.00</b></div><div class="receipt-row"><span>S88-00419 · Venta física</span><b>$2,097.00</b></div></div>`);
   if(b.dataset.modal==='cashbox')info('CAJA Y MOVIMIENTOS',`<p class="info-paragraph">En esta vista se incorporarán la apertura y el cierre de caja, fondo inicial, entradas/salidas justificadas y conciliación.</p><p class="info-paragraph">La base de datos actual <b>no tiene tablas específicas para sesiones y movimientos de caja</b>. Si se aprueba esa funcionalidad, habrá que definirlas antes de programarla.</p>`);
   hideSidebar();
 }));
 $('help-btn').addEventListener('click',()=>info('¿CÓMO USAR EL POS?',`<div class="info-list">1. Selecciona la talla de una prenda en el catálogo.<br>2. Ajusta cantidades en el ticket.<br>3. Vincula un cliente, o conserva «Público general».<br>4. Aplica un cupón, si corresponde.<br>5. Selecciona el método de pago y simula el cobro.<br><br><b>Atajo:</b> Ctrl + K coloca el cursor en el buscador.</div>`));
 $('toggle-menu').addEventListener('click',()=>{$('sidebar').classList.toggle('open');$('sidebar-cover').hidden=!$('sidebar').classList.contains('open');});
 function hideSidebar(){$('sidebar').classList.remove('open');$('sidebar-cover').hidden=true;}
 $('sidebar-cover').addEventListener('click',hideSidebar);
 $('top-date').textContent=new Intl.DateTimeFormat('es-MX',{timeZone:'America/Tijuana',day:'2-digit',month:'short',year:'numeric'}).format(new Date()).toUpperCase();
 renderProducts();updateCustomer();
})();
