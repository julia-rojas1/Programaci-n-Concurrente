9. Resolver el funcionamiento en una fábrica de ventanas con 7 empleados (4 carpinteros, 1 vidriero y 2 armadores) que trabajan de la siguiente manera:
• Los carpinteros continuamente hacen marcos (cada marco es armado por un único carpintero) y los deja en un depósito con capacidad de almacenar 30 marcos.
• El vidriero continuamente hace vidrios y los deja en otro depósito con capacidad para 50 vidrios.
• Los armadores continuamente toman un marco y un vidrio (en ese orden) de los depósitos correspondientes y arman la ventana (cada ventana es armada por un único armador).

cola marcos; // Max 30
int cantMarcos = 0;
sem mutexM = 1;
sem hayMarco = 0;
sem espacioMarcos = 30;

cola vidrios; // Max 50
int cantVidrios = 0;
sem mutexV = 1;
sem hayVidrio = 0;
sem espacioVidrios = 50;

process Carpintero [id: 1 .. 4] {
	while (true) {
		// hace marco
		P(espacioMarcos)
		P(mutexM)
		cantMarcos ++;
		push (marcos, marco)
		V(mutexM)
		V(hayMarco)
	}
}

process Vidriero {
	while (true) {
		// hace vidrio
		P(espacioVidrios)
		P(mutexV)
		cantVidrios ++;
		push (vidrios, vidrio)
		V(mutexV)
		V(hayVidrio)
	}
}

process Armador [id: 1 .. 2] {
	vidrio, marco;
	
	while (true) {
	
	// toma marco
		P(hayMarco)
		P(mutexM)
		cantMarcos --;
		pop (marcos,marco);
		V(mutexM)
		V (espacioMarcos);
		
	// toma vidrio
		P(hayVidrio)
		P(mutexV)
		cantVidrios --;
		pop (vidrios,vidrio);
		V(mutexV)
		V (espacioVidrios);
		
	// arma ventana
	}
}


—--------------------------------------------------------------------------------------------------------------------

10.A una cerealera van T camiones a descargarse trigo y M camiones a descargar maíz. Sólo hay lugar para que 7 camiones a la vez descarguen, pero no pueden ser más de 5 del mismo tipo de cereal. Nota: no usar un proceso extra que actué como coordinador, resolverlo entre los camiones.

sem lugarTotal = 7
sem lugarTrigo = 5
sem lugarMaiz = 5

process CamionTrigo [id: 1 .. T] {
	P(lugarTrigo)
	P(lugarTotal)
	// descarga Trigo
	V(lugarTotal)
	V(lugarTrigo)

}

process CamionMaiz [id: 1 .. M] {
	P(lugarMaiz)
	P(lugarTotal)
	// descarga Maiz
	V(lugarTotal) 
	V(lugarMaiz)

}

—--------------------------------------------------------------------------------------------------------------------

11.En un vacunatorio hay un empleado de salud para vacunar a 50 personas. El empleado de salud atiende a las personas de acuerdo con el orden de llegada y de a 5 personas a la vez. Es decir, que cuando está libre debe esperar a que haya al menos 5 personas esperando, luego vacuna a las 5 primeras personas, y al terminar las deja ir para esperar por otras 5. Cuando ha atendido a las 50 personas el empleado de salud se retira. 
Nota: todos los procesos deben terminar su ejecución; asegurarse de no realizar Busy Waiting; suponga que el empleado tiene una función VacunarPersona() que simula que el empleado está vacunando a UNA persona.

sem vacunados[50] = ([50] 0);
cola personasVacunadas;

cola personas;
int cantEsperando = 0;
sem mutexP = 1; 

sem Hay5Personas = 0;



process Empleado {
	int idPersona, i, j, k;

	for i = 1 .. 10 {
		P(Hay5Personas)
		for j = 1 .. 5 {
			P(mutexP);
			pop (personas,idPersona);
			V(mutexP);
			idPersona.VacunarPersona();
	
			push (personasVacunadas,idPersona)
		}
		for k = 1 .. 5 {
			pop (personasVAcunadas,idPersona)
			V(vacunados[idPersona])
		}
	}
	
	// se retira

}

process Persona [id: 1 .. 50] {

	//llega persona y se encola
	P(mutexP);
	cantEsperando++;
	push (personas,id);
	if (cantESperando == 5) {
		V(Hay5Personas);
		cantEsperando = cantEsperando - 5;
		}
	V(mutexP);
	
	//espera ser vacunada junto con sus 4 compañeros para irse
	P(vacunados[id])
}


—--------------------------------------------------------------------------------------------------------------------

12.Simular la atención en una Terminal de Micros que posee 3 puestos para hisopar a 150 pasajeros. En cada puesto hay una Enfermera que atiende a los pasajeros de acuerdo con el orden de llegada al mismo. Cuando llega un pasajero se dirige al puesto que tenga menos gente esperando. Espera a que la enfermera correspondiente lo llame para hisoparlo, y luego se retira. 
Nota: sólo deben usar procesos Pasajero y Enfermera. Además, suponer que existe una función Hisopar() que simula la atención del pasajero por parte de la enfermera correspondiente.


int cantEsperando[3] = ([3] 0)
cola puestos[3];

sem mutex[3] = ([3] 1);

sem hayPersonas[3] = ([3] 0)
sem hisopados[150] = ([150] 0)

boolean terminado = false;
int cantTotal = 0;
sem mutexTerminado = 1, mutexCant = 1;

process Enfermera [id: 1 .. 3] {
	int idPasajero;
	
	P(hayPersonas[id]);
	while (not terminado){ 
	
		
		P(mutex[id])
		cantEsperando[id]--;
		pop (puestos[id],idPasajero)
		V(mutex[id])
		
		idPasajero.Hisopar()
		V(hisopados[idPasajero])
		
		P(hayPersonas[id]);
	}
}

process Pasajero [id: 1 .. 150] {
	int i;
	int min = 151;
	
	// Averigua el puesto con menos personas esperando
	P(mutexGeneral);
	for i = 1 .. 3 {
		if (cantEsperando[i] < min) {
			min = cantEsperando[i];
			puestoMin = i;
		}					
	}
	cantEsperando[puestoMin]++;
	V(mutexGeneral);
	
	// Se dirige a dicho puesto
	P(mutex[puestoMin])
	push (puestos[puestoMin],id)
	V(mutex[puestoMin])
	V(hayPersonas[puestoMin])
	
	
	P(hisopados[id])
	
	P(mutexCant)
	cantTotal ++;
	if (cantTotal == 150) {
		P(mutexTerminado)
		terminado = true;	
		V(mutexTerminado)
		for j = 1 .. 3 --> V(hayPersonas[j]);
	}
	V(mutexCant)
	
}



