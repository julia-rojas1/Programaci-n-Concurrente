1) Resolver con SEMÁFOROS el siguiente problema.
En una planta verificadora de vehículos, existen 7 estaciones donde se dirigen 150 vehículos para ser verificados. 
Cuando un vehículo llega a la planta, el coordinador de la planta le indica a qué estación debe dirigirse. 
El coordinador selecciona la estación que tenga menos vehículos asignados en ese momento. 
Una vez que el vehículo sabe qué estación le fue asignada, se dirige a la misma y espera a que lo llamen para verificar. 
Luego de la revisión, la estación le entrega un comprobante que indica si pasó la revisión o no. Más allá del resultado, el vehículo se retira de la planta.
Nota: maximizar la concurrencia.

sem llegaAuto = 0;
sem llegaAutoEst[7] = ([7] 0)

cola autos;
sem mutexAutos = 1;

int estacionAutos[150];
sem estacionAsignada[150] = ([150] 0);

sem mutexEstacion = 1;
int cantEstacion[7] = ([7] 0)
sem mutexEstacionCola[7] = ([7] 1)
cola colaEstacion[7]; // vector de colas

boolean comprobantes[150];
sem autoRevisado[150] = ([150] 0)

process Estación [id: 1 .. 7] {
	boolean resultado;
	int idAuto;

	while (true) {			// ¿LOS PROCESOS DEBEN TERMINAR? 
		P(llegaAutoEst[id])
		
		P(mutexEstacionCola[id])
		pop(colaEstacion[id],idAuto);
		V(mutexEstacionCola[id])
		
		resultado = // revisa auto idAuto
		
		comprobantes[idAuto] = resultado;
		V(autoRevisado[idAuto]);
		
	}
}

process Vehículo [id: 1 .. 150]{
	// llega a la planta
	P(mutexAutos)
	push (autos,id)
	V(mutexAutos)
	V(llegaAuto) 
	
	// espera que el coordinador le indique a que estación dirigirse
	P(estacionAsignada[id])
	estacion = estacionAutos[id];
	
	// se dirige a la estación
	P(mutexEstacionCola[estacion]) 
	push (colaEstacion[estacion],id) // No se si debería encolarlo el coordinador para que nadie se cole
	V(mutexEstacionCola[estacion])
	V(llegaAutoEst[estacion])
	
	// espera que lo revisen y se retira 
	P(autoRevisado[id]);
	comprobante = comprobantes[id];
	P(mutexEstacion)
	cantEstacion[estacion]--;
	V(mutexEstacion)
	
}

process Coordinador {
	int idAuto, i, estacion, min = 151;
	
	while (true) {
		// espera que llegue vehículo
		P(llegaAuto)
		P(mutexAutos)
		pop (autos,idAuto)
		V(mutexAutos)
		
		// selecciona la estación que tenga menos vehículos asignados
		P(mutexEstacion)
		for i = 1 .. 7 {
			if (cantEstacion[i] < min) {
				min = cantEstacion[i];
				estacion = i;
			}
		}
		estacionAutos[estacion]++;
		V(mutexEstacion)
		
		// le asigna estación
		estacionAutos[idAuto] = estacion; 
		V(estacionAsignada[idAuto]);	
	}
}



2) Resolver con MONITORES el siguiente problema. 
En un sistema operativo se ejecutan 20 procesos que periódicamente realizan cierto cómputo mediante la función Procesar(). 
Los resultados de dicha función son persistidos en un archivo, para lo que se requiere de acceso al subsistema de E/S. 
Sólo un proceso a la vez puede hacer uso del subsistema de E/S, y el acceso al mismo se define por la prioridad del proceso (menor valor indica mayor prioridad).

Monitor Subsistema {
	text archivo;
	
	boolean libre = true;
	colaOrdenada espera;
	int cantEsperado = 0;
	cond esperaProcesos[20];
	
	procedure solicitarAcceso(id,prioridad: in int) {
		if (not libre) {
			cantEsperando++;
			push(espera,(id,prioridad)) // Se inserta ordenado por prioridad
			wait (esperaProcesos[id])
		}
		else libre = false;
	}
	
	procedure salir() {
		if (esperando > 0) {
			cantEsperando--;
			pop(espera(idProceso,prioridad));
			signal (esperaProcesos[idProceso])
		}
		else libre = true;
	}

}

process Proceso [id: 1 .. 20] {
	text resultado;
	int prioridad = getPrioridad();

	while (true) {
		resultado = Procesar()
		Subsistema.solicitarAcceso(id,prioridad)
		
		// Persistir resultado en archivo 
		
		Subsistema.salir()
	}
}

