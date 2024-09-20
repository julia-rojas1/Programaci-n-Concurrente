1. SEMÁFOROS. Existen 15 sensores de temperatura y 2 módulos centrales de procesamiento. Un sensor mide la temperatura cada cierto tiempo (función medir()), la envía al módulo central para que le indique qué acción debe hacer (un número del 1 al 10) (función determinar() para el módulo central) y la hace (función realizar()). Los módulos atienden las mediciones por orden de llegada.

sem mutexTemp = 1
cola temperaturas; // guarda pares (idSensor,temperatura)

sem HayTemperatura = 0;

sem mutexAcciones = 1;
sem HayAcción[15] = ([15] 0)

int accionPorSensor[15];


process SensorTemperatura [id: 1.. 15] {
	double temperatura; 

	while (true) {
		// mide temperatura y la envía
		temperatura = medir();
		P(mutexTemp)
		push(temperaturas,(id,temperatura))
		V(mutexTemp)
		
		V(HayTemperatura)
		
		// espera nro de acción
		P(HayAccion[id]);
		
		// realiza acción
		realizar(accionPorSensor[id]); // Paso como parámetro la acción que le fue asignada para realizar
	}
	
}

process moduloCentral [id: 1 .. 2] {
	int idSensor, accion;
	double temperatura;

	while (true) {
		// espera temperatura
		P(HayTemperatura)
		
		// envía nro de acción
		P(mutexTemp)
		pop(temperaturas,(idSensor,temperatura))
		V(mutexTemp)
		
		accionPorSensor[idSensor] = determinar(temperatura);
		
		V(HayAccion[idSensor])
	
	}
}


2. MONITORES. Una boletería vende E entradas para un partido, y hay P personas (P>E) que quieren comprar. Se las atiende por orden de llegada y la función vender() simula la venta. La boletería debe informarle a la persona que no hay más entradas disponibles o devolverle el número de entrada si pudo hacer la compra.

Monitor Fila {
	cond espera;
	int cantEsperando = 0
	boolean libre = true;
	
	procedure hacerFila() {
		if (not libre) {
			cantEsperando ++;
			wait (espera)
		}
		else libre = true;
	}
	
	procedure irmeFila() {
		if (cantEsperando > 0) {
			cantEsperando --;
			signal (espera)
		}
		else libre = true
	}

}

Monitor Boleteria {

	

}

process Persona [id: 1 .. P] {
	Fila.hacerFila()
	
	// mientras haya entradas --> comprar entrada
	
	Fila.irmeFila();
}





3. MONITORES. Por un puente turístico puede pasar sólo un auto a la vez. Hay N autos que quieren pasar (función pasar()) y lo hacen por orden de llegada.

