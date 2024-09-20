1. Resolver con SEMÁFOROS el siguiente problema. 
En un restorán trabajan C cocineros y M mozos. De forma repetida, los cocineros preparan un plato y lo dejan listo en la bandeja de platos terminados, mientras
que los mozos toman los platos de esta bandeja para repartirlos entre los comensales. Tanto los cocineros como los mozos trabajan de a un plato por vez. 
Modele el funcionamiento del restorán considerando que la bandeja de platos listos puede almacenar hasta P platos. 
No es necesario modelar a los comensales ni que los procesos terminen.

cola bandejaPlatosListos; // max P platos
sem mutexBandeja = 1;
sem hayLugar = P;
sem hayPlato = 0;


process Cocinero [id: 1 .. C] {

	while (true) {
		plato = // prepara plato
		// lo deja listo en la bandeja de platos terminados
		P(hayLugar)
		P(mutexBandeja)
		push(bandejaPlatosListos, plato)
		V(mutexBandeja)
		V(hayPlato)
	}

}


process Mozo [id: 1 .. M] {

	while (true) {
		// esperan plato listo en la bandeja de platos terminados
		P(hayPlato)
		// toma plato
		P(mutexBandeja)
		pop(bandejaPlatosListos, plato)
		V(mutexBandeja)
		V(hayLugar)
		// reparte plato a comensal
	}

}

// REPASAR BUFFERS CIRCULARES


2. Resolver con MONITORES el siguiente problema. 
En una planta verificadora de vehículos existen 5 estaciones de verificación. 
Hay 75 vehículos que van para ser verificados, cada uno conoce el número de estación a la cual debe ir. 
Cada vehículo se dirige a la estación correspondiente y espera a que lo atiendan.
Una vez que le entregan el comprobante de verificación, el vehículo se retira. Considere que en cada estación se atienden a los vehículos de acuerdo con el orden de llegada. 
Nota: maximizar la concurrencia.

monitor FilaEstación [id: 1 .. 5] {
	boolean libre = true;
	cola esperando;
	int cantEsperando = 0;
	
	procedure llegada() {
		if (not libre) {
			cantEsperando++;
			wait(esperando);
		}
		else libre = false;
	}
	
	procedure salida() {
		if (cantEsperando > 0) {
			cantEsperando--;
			signal(esperando);
		}
		else libre = true;
	}
}

monitor Estación [id: 1 .. 5] {
	procedure verificación (auto: in int, comprobante: out boolean) {
		comprobante = Verificar(auto);
	}
}

process Vehículo [id: 1 .. 75] {
	int nroEstacion = getNroEstación();
	boolean comprobante;
	
	FilaEstación[nroEstacion].llegada();
	
	Estación[nroEstacion].verificación(comprobante)
	
	FilaEstación[nroEstacion].salida();
}

