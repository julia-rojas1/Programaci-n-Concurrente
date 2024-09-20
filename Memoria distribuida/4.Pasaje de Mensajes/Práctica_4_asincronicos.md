### Ejercicio 1
Suponga que N clientes llegan a la cola de un banco y que serán atendidos por sus empleados. Analice el problema y defina qué procesos, recursos y comunicaciones serán necesarios/convenientes para resolver el problema. Luego, resuelva considerando las siguientes situaciones:

#### Inciso A
Existe un único empleado, el cual atiende por orden de llegada.
```java

chan Fila(int);
chan Listo[N](boolean)

process Cliente [id: 1 .. N] {
	boolean ok;
	send Fila(id);
	receive Listo[id](ok);
} 

process Empleado {
	for i = 1 .. N {
		receive Fila(idCliente)
		// atender cliente con idCliente
		send Listo[idCliente](True);
	}
}
```

#### Inciso B
Ídem a) pero considerando que hay 2 empleados para atender, ¿qué debe modificarse en la solución anterior?
```java
chan Fila(int);
chan Listo[N](boolean)

process Cliente [id: 1 .. N] {
	boolean ok;
	send Fila(id);
	receive Listo[id](ok);
} 

process Empleado [id: 1 .. 2] {
	while (true){ // TODO: preguntar while true con N personas
		receive Fila(idCliente)
		// atender cliente con idCliente
		send Listo[idCliente](True);
	}
}
```

#### Inciso C
Ídem c) pero considerando que, si no hay clientes para atender, los empleados realizan tareas administrativas durante 15 minutos. ¿Se puede resolver sin usar procesos adicionales? ¿Qué consecuencias implicaría?
```java

chan Fila(int);
chan Listo[N](boolean);
chan Libre(int);
chan Siguiente[2](int);

process Ciente[id: 1 .. N] {
	boolean ready;
	send Fila(id);
	receive Listo[id](ready);
}

process Administrador {
	int i, idCliente, idEmpleado;
	while (true) {
		receive Libre(idEmpleado);
		if (empty(Fila)) {
			idCliente = -1;
		}
		else {
			receive Fila(idCliente);
		}
		send Siguiente[idEmpleado](idCliente);
	}
}

process Empleado[id: 1 .. 2] {
	while (true) {
		send Libre(id);
		receive Siguiente[id](idCliente);
		if (idCliente <> -1) {
			//Atiende cliente
			send Listo[idCliente](true);
		}
		else delay (15 minutos);
	}
}

-----------------------------------------------------------------------
chan Fila(int); 
chan Listo[N](boolean) // Para liberar al cliente
chan Libre (int) // Para el coordinador
chan Siguiente[2] (int) // Para los empleados

process Cliente [id: 1 .. N] {
	boolean ok;
	send Fila(id);
	receive Listo[id](ok);
} 

process Empleado [id: 1 .. 2] {
	int idCliente;
	while (true){
		send Libre (id)
		receive Siguiente[id] (idCliente)
		if (idCliente != -1) {
			// atender cliente con idCliente
			send Listo[idCliente](true);
		}
		else delay (900) // realiza tarea administrativa durante 15 minutos
	}
}

process Coordinador {
	int idEmpleado, idCliente;
	while (true) {
		receive Libre (idEmpleado);
		if (empty(Fila)) idCliente = -1;
		else receive Fila (idCliente);

		send Siguiente[idEmpleado] (idCliente);
	}
}
```
-------------------------------------------------------------------------------------------------
### Ejercicio 2
Se desea modelar el funcionamiento de un banco en el cual existen 5 cajas para realizar pagos.
Existen P clientes que desean hacer un pago. 
Para esto, cada una selecciona la caja donde hay menos personas esperando; una vez seleccionada, espera a ser atendido. 
En cada caja, los clientes son atendidos por orden de llegada por los cajeros. Luego del pago, se les entrega un comprobante. Nota: maximizando la concurrencia.

```java

process Cliente[id: 1 .. N] {
	send SeleccionarCaja(id);
	send Pedido();

	receive NroCaja[id](idCaja);

	send Pago[idCaja](id,plata);
	receive Comprobante[id](comprobante);

	send LiberarCaja(idCaja);
	send Pedido();
}

process Cajero[id: 1 .. 5] {
	while (true) {
		receive Pago[id](idCliente,plata);
		comprobante = procesarPago(plata);
		send Comprobante[idCliente](comprobante);
	}
}

process Administrador {
	int[5] persXcaja = ([5] 0);

	while (true) {
		receive Pedido();
		if (emty(LiberarCaja)) {
			receive SeleccionarCaja(idCliente);
			idCaja = min(persXcaja);
			send NroCaja[idCliente](idCaja);
			persXcaja[idCaja]++;
		}
		else {
			receive LiberarCaja(idCaja);
			persXcaja[idCaja]--;
		}
	}

}


-----viejo------------------------------------------------------

/* chan Solicitud(int, int) // idCliente/idNroCaja, 1=llega/0=sale

process Cliente [id: 1 .. P] {
	text comp;
	int nroCaja;

	send Solicitud (id,1) 
	receive AsignarCaja[id] (nroCaja)

	send FilaCaja[nroCaja](id)
	receive comprobante[id](comp)
	send Solicitud (nroCaja,0)
	
}

process Cajero [id: 1 .. 5] {
	text comp;
	while (true) {
		receive FilaCaja[id](idCliente)
		comp = //realizar pago del cliente idCliente
		send comprobante[idCliente](comp)
	}
}

process Coordinador {
	int filaCajeros[5] = ([5] 0);
	int min = P + 1;

	while (true) {
		receive Solicitud(id,operacion)
		if (operacion = 1) { // Cliente llega para ponerse en una fila, envía en id su idCliente
			for i = 1 .. 5 {
				if (filaCajeros[i] < min) {
					min = filaCajeros[i];
					minCaja = i;
				}
			}
			filaCajeros[minCaja]++;

			send AsignarCaja[id] (minCaja)
		}
		else if (operacion = 0) { // Cliente sale de la fila, envía en id el nro de Caja
			filaCajeros[id] --;
		}
	}
} */
```
-------------------------------------------------------------------------------------------------
### Ejercicio 3
Se debe modelar el funcionamiento de una casa de comida rápida, en la cual trabajan 2 cocineros y 3 vendedores, y que debe atender a C clientes. El modelado debe considerar que:
- Cada cliente realiza un pedido y luego espera a que se lo entreguen.
- Los pedidos que hacen los clientes son tomados por cualquiera de los vendedores y se lo pasan a los cocineros para que realicen el plato. Cuando no hay pedidos para atender, los vendedores aprovechan para reponer un pack de bebidas de la heladera **(tardan entre 1 y 3 minutos para hacer esto)**.
- Repetidamente cada cocinero toma un pedido pendiente dejado por los vendedores, lo cocina y se lo entrega directamente al cliente correspondiente.
Nota: maximizar la concurrencia.

```java
chan Libre(int)
chan Siguiente[3](text)

chan PedidosDeCliente(int,text)
chan PedidosVendedor(int,text)
chan PedidosCocinados[C](text) 

process Cocinero [id: 1 .. 2] {
	text pedido, pedidoCocinado;
	int idCliente;
	while (true) {
		// toma pedido dejado por vendedor
		receive PedidosVendedor(idCliente,pedido);
		// cocina el pedido
		pedidoCocinado = cocinar(pedido);
		// lo entrega al cliente correspondiente
		send PedidosCocinados[idCliente](pedidoCocinado);
	}
}

process Vendedor [id: 1 .. 3] {
	text pedido;
	int idCliente;
	while (true) {
		send Libre(id);
		receive Siguiente[id] (pedido);

		// Si hay pedido, se lo pasan a los cocineros
		if (pedido != "Vacío") {
			send PedidosVendedor(idCliente,pedido)
		}
		// si no hay pedido repone pack de bebidas
		else delay(random(1,3)) 
	}
}

process Coordinador {
	text pedido;
	int idVendedor;

	while (true) {
		receive Libre (idVendedor);
		if (empty(PedidosVendedor)) pedido = "Vacío";
		else receive PedidosVendedor (pedido);

		send Siguiente[idVendedor](pedido);
	}

}

process Cliente [id: 1 .. C] {
	text pedido;
	// realiza pedido
	send PedidosDeCliente(id,pedido)
	// espera que se lo entreguen
	receive PedidosCocinados[id](pedido)
}
```

-------------------------------------------------------------------------------------------------
### Ejercicio 4
Simular la atención en un locutorio con 10 cabinas telefónicas, el cual tiene un empleado que se encarga de atender a N clientes. 
Al llegar, cada cliente espera hasta que el empleado le indique a qué cabina ir, la usa y luego se dirige al empleado para pagarle. 
El empleado atiende a los clientes en el orden en que hacen los pedidos, pero siempre dando prioridad a los que terminaron de usar la cabina. A cada cliente se le entrega un ticket factura. 
Nota: maximizar la concurrencia; suponga que hay una función Cobrar() llamada por el empleado que simula que el empleado le cobra al cliente.

```java
//TODO: CHEQUEAR -> :)

chan Pedido();
chan SolicitarCabina(int);
chan NroCabina[N](int);
chan PagarCabina(int,int);
chan Factura[N](String)

process Cliente[id: 1 .. N] {
	int idCabina;
	String factura;

	send SolicitarCabina(id)
	send Pedido()
	receive NroCabina[id](idCabina);
	// usa cabina
	send PagarCabina(id,idCabina);
	send Pedido()
	receive Factura[id](factura);
}

process Empleado {
	Cola idCabinas; // ids de las cabinas, inicializado en (1,2,..,9,10)
	Cola idClientes;
	int esperando = 0;
	int idCabina, idCliente;

	while (true) {
		receive Pedido();

		if (empty(PagarCabina)) {
			receive SolicitarCabina(idCliente);
			if (not empty(idCabinas)) {
				pop (idCabinas, idCabina);
				send NroCabina[idCliente](idCabina);
			}
			else {
				esperando++;
				push (clientesEsperando,idCliente);
			}
		} 
		else {
			receive PagarCabina(idCliente, idCabina);
			factura = Cobrar();
			send Factura[idCliente](factura);
			
			
			if (esperando > 0) {
				esperando --
				pop (clientesEsperando,idCliente)
				send NroCabina[idCliente](idCabina);
			}
			else {
				push (idCabinas, idCabina);
			}
		}

	}

}


// Solución óptima

while (true) {
		receive Pedido();

		if (empty(PagarCabina) && not empty(idCabinas)) {
			receive SolicitarCabina(idCliente);
			pop (idCabinas, idCabina);
			send NroCabina[idCliente](idCabina);
		} 
		else {
			receive PagarCabina(idCliente, idCabina);
			factura = Cobrar();
			send Factura[idCliente](factura);
			push (idCabinas, idCabina);
			
		}

	}

------viejo-------------------------------------------------------

/* chan HayCliente(int) 
chan Llegada(int)
chan Salida(int)

chan Cabinas[N](int)
chan CabinaLiberada(int)
chan Tickets[N](text)

process Empleado {
	int operacion;
	cola<int> colaCabinas; 
	int cabina;
	text ticket;
	int llegada=0, salida=0;

	for i = 1 .. 10 { // inicializa la cola con los id de las cabinas (1, 2, 3, ..., 9, 10)
		push (colaCabinas,i)
	}

	while (true) {
		while (not empty(HayCliente)) {
			receive HayCliente(operacion);
			if (operacion = 1) llegada++;
			else if (operacion = 0) salida++;
		}

		if (salida > 0) { // dando prioridad a los que terminaron de usar la cabina
			receive Salida(idCliente)
			salida --;
			receive CabinaLiberada(cabina)
			push (colaCabinas,cabina)
			ticket = Cobrar()
			send Tickets[idCliente] (ticket)
		}
		else if ((llegada > 0) && (not empty(colaCabinas))) {
			receive Llegada(idCliente)
			llegada --;
			pop (colaCabinas,cabina); 
			send Cabinas[idCliente] (cabina);
		}
	}
}

process Cliente [id: 1 .. N] {
	int cabina;
	text ticket;

	send HayCliente(1)
	send Llegada(id)
	receive Cabinas[id](cabina);

	usarCabina(cabina);

	send HayCliente(0,id)
	send Salida(id)
	send CabinaLiberada (cabina)
	receive Tickets[id](ticket)
} */
```

-------------------------------------------------------------------------------------------------
5. Resolver la administración de las impresoras de una oficina. Hay 3 impresoras, N usuarios y
1 director. Los usuarios y el director están continuamente trabajando y cada tanto envían
documentos a imprimir. Cada impresora, cuando está libre, toma un documento y lo
imprime, de acuerdo con el orden de llegada, pero siempre dando prioridad a los pedidos
del director. Nota: los usuarios y el director no deben esperar a que se imprima el
documento.
```java
//TODO: CHEQUEAR -> :)

chan PedidosUsuario(String);
chan PedidosDirector(String);
chan Pedidos();

process Usuario[id: 1 .. N] {
	while (true) {
		documento = trabajar();
		send PedidosUsuario(documento);
		send Pedido();
	}
}

process Director {
	while (true) {
		documento = trabajar();
		send PedidosDirector(documento);
		send Pedido();
	}
}

process Impresora[id 1 .. 3] {
	while (true) {
		send ImpLibre(id);
		receive Imprimir[id](documento);
		Imprimir(documento);
	}
}

process Admin {
	while (true) {
		receive ImpLibre(idImpresora);
		receive Pedido();
		if (not Empty(PedidosDirector)) {
			receive PedidosDirector(documento);
		}
		else {
			receive PedidosUsuario(documento);
		}
		send Imprimir[idImpresora](documento);
	}
}

```