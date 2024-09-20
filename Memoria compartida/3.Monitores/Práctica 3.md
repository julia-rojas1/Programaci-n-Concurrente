1 Se dispone de un puente por el cual puede pasar un solo auto a la vez. Un auto pide permiso para pasar por el puente, cruza por el mismo y luego sigue su camino.


Monitor Puente
     cond cola; 
     int cant= 0;

     Procedure entrarPuente ()
          while ( cant > 0) wait (cola);
          cant = cant + 1; 
     end;

     Procedure salirPuente ()
          cant = cant – 1;
          signal(cola);
     end;
End Monitor;

Process Auto [a:1..M]
      Puente. entrarPuente (a);
      “el auto cruza el puente”
      Puente. salirPuente(a);
End Process;


a. ¿El código funciona correctamente? Justifique su respuesta.
Sí, funciona correctamente. Se cumple lo de que pase un auto por el puente a la vez, dada la naturaleza de los monitores de implementar exclusión mutua, y le agrega un orden de llegada para los autos encolados.
Lo único que no me cierra es el parámetro “a” que envía en las invocaciones a los procedures.

b. ¿Se podría simplificar el programa? ¿Sin monitor? ¿Menos procedimientos? ¿Sin variable condition? En caso afirmativo, rescriba el código.
Sí, como el monitor implementa la exclusión mutua implícitamente podría reducirse a lo siguiente:

Monitor Puente
{
       Procedure entrarPuente ()
       { 
              pasarPuente ();
       }
}
End Monitor;

Process Auto[id: 0..N-1]
{ 
Puente.pasarPuente();
}



c. ¿La solución original respeta el orden de llegada de los vehículos? Si rescribió el código en el punto b), ¿esa solución respeta el orden de llegada?

No, la solución original lo respeta parcialmente. Solo para los autos que están encolados. La b) no lo respeta en absoluto.
Para respetar el orden completamente, podría considerarse la siguiente solución: 

Monitor Puente
     bool libre = true;
     cond cola; 
     int esperando = 0;

     Procedure entrarPuente () 
          if (not libre) {
esperando ++;
wait (cola)      
          }
         else libre = false;
     end;

     Procedure salirPuente ()
           if (esperando > 0) {
	esperando –;
	signal (cola)
}
else libre = true;
     end;
End Monitor;

Process Auto [a:1..M]
      Puente. entrarPuente ();
      “el auto cruza el puente”
      Puente. salirPuente();
End Process;

—--------------------------------------------------------------------------------------------------------------
2. Existen N procesos que deben leer información de una base de datos, la cual es administrada por un motor que admite una cantidad limitada de consultas simultáneas.

a) Analice el problema y defina qué procesos, recursos y monitores serán 
necesarios/convenientes, además de las posibles sincronizaciones requeridas para 
resolver el problema.
Procesos: 
- Lectores (1 .. N):	envían solicitud de lectura al motor
			esperan que sea aceptada
leen
 
- Motor: 		espera solicitud de lectura
admite solicitud de lectura

Monitores:
- Base de Datos	



b) Implemente el acceso a la base por parte de los procesos, sabiendo que el motor de 
base de datos puede atender a lo sumo 5 consultas de lectura simultánea

Monitor BD {
	cond esperaLectores;
	int esperando = 0; // Procesos Lectores esperando para acceder a la bd
int cantLibres = 5; // A lo sumo 5 consultas de lectura simultánea

	Procedure solicitudEnviada() {
		if (cantLibres == 0) {
			esperando ++;
			wait (esperaLectores);
		}
		else cantLibres - -;
	}

	Procedure solicitudProcesada() {
		if (esperando > 0) {
			esperando - -;
			signal(esperaLectores);
}
else cantLibres ++;
}
}

Process Lector [id: 1 .. N] {
	while (true) {
	BD.solicitudEnviada();
	// Accede a la base de datos
	BD.solicitudProcesada();
}
}



—--------------------------------------------------------------------------------------------------------------

3. Existen N personas que deben fotocopiar un documento. La fotocopiadora sólo puede ser
usada por una persona a la vez. 
Analice el problema y defina qué procesos, recursos y monitores serán necesarios/convenientes, además de las posibles sincronizaciones requeridas para resolver el problema. Luego, resuelva considerando las siguientes situaciones:

a) Implemente una solución suponiendo que no importa el orden de uso. Existe una función
Fotocopiar() que simula el uso de la fotocopiadora.

Monitor Fotocopiadora {

	procedure fotocopiar() {
		Fotocopiar();
}
}

Process Persona [id: 1 .. N] {
	Fotocopiadora.fotocopiar();
}


b) Modifique la solución de (a) para el caso en que se deba respetar el orden de llegada.

Monitor Fotocopiadora {
	bool libre = true;
	cond cola;
	int esperando = 0;

	procedure usar() {
		 if (not libre) { esperando ++;
 wait (cola); } 
else libre = false;
}

procedure terminó() {
	if (esperando > 0 ) { esperando --; 
signal (cola); } 
else libre = true;
}
}

Process Persona [id: 1 .. N] {
	Fotocopiadora.usar();
	Fotocopiar();
	Fotocopiadora.terminó();
}


c) Modifique la solución de (b) para el caso en que se deba dar prioridad de acuerdo con la
edad de cada persona (cuando la fotocopiadora está libre la debe usar la persona de mayor
edad entre las que estén esperando para usarla).

Monitor Fotocopiadora {
	bool libre = true;
	cond espera[N]; // Para avisar particularmente a c/ persona cuando es su turno
	int idAux, esperando = 0;
	colaOrdenada fila; // se encolan ordenados por edad

	procedure usar(idP, edad: in int) {
		 if (not libre) { insertar(fila,idP,edad);
 esperando ++;
 wait (espera[idP]); } 
else libre = false;
}

procedure terminó() {
	if (esperando > 0 ) {  esperando --; 
				sacar (fila,idAux);
signal (espera[idAux]); } 
else libre = true;
}
}

Process Persona [id: 1 .. N] {
	bool edad = leerEdad();

	Fotocopiadora.usar(id, edad);
	Fotocopiar();
	Fotocopiadora.terminó();
}


d) Modifique la solución de (a) para el caso en que se deba respetar estrictamente el orden
dado por el identificador del proceso (la persona X no puede usar la fotocopiadora hasta
que no haya terminado de usarla la persona X-1).











Monitor Fotocopiadora {
	int turnoActual = 1;
cond espera[N];
bool llegó[N] = ([N] false)

	procedure fotocopiar(id: in int) {
		if (turnoActual <> id) { // Si no es mi turno todavía
			llegó[id] = true; // Aviso que llegué
			wait (espera[id]); // Espero mi turno	
}

// Si el turnoActual == id
Fotocopiar();
		turnoActual ++;

if (llegó[turnoActual]) { 
signal (espera[turnoActual]);
} //Prestar atención en el último caso
	}
}

Process Persona [id: 1 .. N] {
	Fotocopiadora.fotocopiar(id);
}




e) Modifique la solución de (b) para el caso en que además haya un Empleado que le indica
a cada persona cuando debe usar la fotocopiadora.

Monitor Fotocopiadora {
	bool llegóEmpleado = false;
	cond cola;
	int esperando = 0;
	cond hayPersonas;

	procedure llegaEmpleado() {
		llegóEmpleado = true;
	}

procedure llegada() {
		esperando ++;
wait (cola); 

if (esperando == 1) && (llegóEmpleado) {
signal (hayPersonas)
}
}

procedure próximo() {
	if (esperando == 0) {
		wait (hayPersonas)
	}
	if (esperando > 0 ) { 
esperando --; 
signal (cola); 
} 
}
}

Process Persona [id: 1 .. N] {
	Fotocopiadora.llegada();
	Fotocopiar(); // Revisando me di cuenta que faltaria avisar cuando termina de usarla para que no se pisen. Supongo que con un boolean libre bastaría
}

Process Empleado {
	Fotocopiadora.llegaEmpleado();
for i = 1 ..N {
		Fotocopiadora.próximo();
}
}



f) Modificar la solución (e) para el caso en que sean 10 fotocopiadoras. El empleado le indica a la persona cuál fotocopiadora usar y cuándo hacerlo.

Monitor Fotocopiadora {
	bool llegóEmpleado = false;
c	ond hayPersonas;

	cond cola;
	int esperando = 0;

	cola colaFotocopiadora;
	int cantLibres;
	int fotocopiadora; // asignar puntualmente a cada empleado mediante un array
	
	procedure llegaEmpleado() {
		llegóEmpleado = true;
		for i = 1 .. 10 {
			push (colaFotocopias, i) // i = nro de fotocopiadora
}
cantLibres = 10;
	}

procedure llegada(fot: out int) {
		esperando ++;

if (esperando == 1) && (llegóEmpleado) {
signal (hayPersonas)
}

wait (cola); 

fot = fotocopiadora
}

procedure liberada(fot: in int) {
	cantLibres++;
	push(colaFotocopiadora,fot);
}

procedure próximo() {
	if (esperando == 0) {
		wait (hayPersonas)
	}
	
	if (esperando > 0 ) && (cantLibres > 0) { 
esperando --; 
cantLibres --;
pop(colaFotocopiadoras,fotocopiadora)
signal (cola); 
} 

}
}

Process Persona [id: 1 .. N] {
	int fotocopiadora;
	Fotocopiadora.llegada(fotocopiadora);
	Fotocopiar() en fotocopiadora;
	Fotocopiadora.liberada(fotocopiadora);
}

Process Empleado {
	Fotocopiadora.llegaEmpleado();
	while (true) {
		Fotocopiadora.próximo();
}
}


—--------------------------------------------------------------------------------------------------------------

4. Existen N vehículos que deben pasar por un puente de acuerdo con el orden de llegada.
Considere que el puente no soporta más de 50000 kg y que cada vehículo cuenta con su propio peso (ningún vehículo supera el peso soportado por el puente).

Monitor Puente {
int pesoActual = 0;
int pesoAcumulado = 0;

cola pesosAutos;
int pesoProx;
int pesosProximos;

cond cola;
int esperando = 0;

Procedure pasar(peso,id: in int) {
	if (pesoAcumulado + peso > 50.000) or (esperando > 0) { 	
esperando ++;
pesoAcumulado += peso;
		push (pesosAutos,peso)
		wait (cola);
}

else 	pesoAcumulado += peso;

pesoActual += peso;

}

Procedure salir(peso,id: in int) {
	pesoActual = pesoActual - peso;
	pesoAcumulado = pesoAcumulado - peso;

pop (pesosAutos, pesoProx)
pesosProximos = pesoProx
	while (esperando >0) && (pesoActual + pesosProximos <= 50.000){
		esperando --;
		signal (cola)
		if (esperando > 0) {
pop (pesosAutos, pesoProx)
pesosProximos + = pesoProx;
}
	}
	if  (pesoActual + pesosProximos > 50.000) {
		insertarAdelante (pesosAutos, pesoProx)
	}

}
}

Process Auto [id:1 .. N] {
	int peso = LeerPeso()

	Puente.pasar(peso,id);
	// Cruzar puente
	Puente.salir(peso,id);
}


—--------------------------------------------------------------------------------------------------------------

5. En un corralón de materiales se deben atender a N clientes de acuerdo con el orden de llegada.
Cuando un cliente es llamado para ser atendido, entrega una lista con los productos que
comprará, y espera a que alguno de los empleados le entregue el comprobante de la compra realizada.

a) Resuelva considerando que el corralón tiene un único empleado.
b) Resuelva considerando que el corralón tiene E empleados (E > 1).

Monitor Corralón {
	cola empLibres;
	int cantLibres = 0;

	cond esperaClientes;
	int esperando = 0;

	procedure llegada (idEmpleado: out int) {
		if (cantLibres == 0) {
			esperando ++;
			wait (esperaClientes);
		}
		else cantLibres --;
		pop (empLibres, idEmpleado);
	}

	procedure próximo (idEmpleado: in int) {
		push (empLibres, idEMpleado);
		if (esperando > 0) {
			esperando --;
			signal (esperaClientes);
		}
		else cantLibres ++;
}
}

Monitor Escritorio [id: 1 .. E] {
	cond vcCliente, vcEmpleado;
	text lista ,comprobante;
	boolean listo = false;

	procedure comprar (l: int text; c: out text) {
		lista = l;
		listo = true;

		signal (vcEmpleado);
		wait (vcCliente);
		
		c = comprobante;
		signal (vcEmpleado);	
	}

	procedure esperarLista (l: out text) {
		if (not listo) wait (vcEmpleado);
		l = lista;
	}

	procedure EnviarComprobante (c: in text) {
		comprobante = c;
		signal (vcCliente);
		wait (vcEmpleado);
		listo = false;
	}
}

process Cliente [id: 1 .. N] {
	int idEmpleado;
	text lista = crear lista;
	text comprobante;

	Corralon.llegada (idEmpleado);
	Escritorio[idEmpleado].comprar(lista,comprobante);
}

process Empleado [id: 1 .. E] {
	text comprobante;
	text lista;
	
	for i = 1 .. N {
		Corralon.póximo(id);
		Escritorio[id].esperarLista (lista);
		comprobante = suma de elementos de la lista;
		Escritorio[id].enviarComprobante(comprobante);
	}
}

6. Existe una comisión de 50 alumnos que deben realizar tareas de a pares, las cuales son
corregidas por un JTP. 
Cuando los alumnos llegan, forman una fila. 
Una vez que están todos en fila, el JTP les asigna un número de grupo a cada uno. Para ello, suponga que existe una función AsignarNroGrupo() que retorna un número “aleatorio” del 1 al 25. 
Cuando un alumno ha recibido su número de grupo, comienza a realizar su tarea. 
Al terminarla, el alumno le avisa al JTP y espera por su nota. 
Cuando los dos alumnos del grupo completaron la tarea, el JTP les asigna un puntaje (el primer grupo en terminar tendrá como nota 25, el segundo 24, y así sucesivamente hasta el último que tendrá nota 1). 
Nota: el JTP no guarda el número de grupo que le asigna a cada alumno.

Monitor JTP {
	int cant = 0;
	cond espera;
	
	int gruposFinalizados[25] = ([25] 0)
	cond esperaGrupos[25];

	int notaGrupos[25];
	int nota = 25;

	procedure llegada() {
		cant ++ ;
		if (cant == 50) signal_all (espera);
		else wait (espera);
	}

	procedure solicitarNro (nroGrupo: out int) {
		nroGrupo = AsignarNroGrupo();
	}

	procedure tareaFinalizada (nroGrupo: in int) {
		gruposFinalizados[nroGrupo] ++;
		if (gruposFinalizados[nroGrupo]  == 2) {
			signal (esperaGrupos[nroGrupo]);
			notaGrupos[nroGrupo] = nota;
			nota --;
		}
		else wait (esperaGrupos[nroGrupo]);
	}

	procedure accederNota (nroGrupo: in int, nota: out int) {
		nota = notaGrupo[nroGrupo];
	}
}


process Alumno[id: 1 .. 50] {
	int nro, nota;

	JTP.llegada()
	JTP.solicitarNro(nro);
	//realiza tarea
	JTP.tareaFinalizada(nro)
	JTP.accederNota(nro,nota);
}


7. En un entrenamiento de fútbol hay 20 jugadores que forman 4 equipos (cada jugador conoce el equipo al cual pertenece llamando a la función DarEquipo()). 
Cuando un equipo está listo (han llegado los 5 jugadores que lo componen), debe enfrentarse a otro equipo que también esté listo (los dos primeros equipos en juntarse juegan en la cancha 1, y los otros dos equipos juegan en la cancha 2). 
Una vez que el equipo conoce la cancha en la que juega, sus jugadores se dirigen a ella. 
Cuando los 10 jugadores del partido llegan a la cancha comienza el partido, juegan durante 50 minutos, y al terminar todos los jugadores del partido se retiran (no es necesario que se esperen para salir).

Monitor AdministradorCanchas{
	int nroCancha = 1;
	int equipos = 0;

	procedure asignarCancha(nro: out in) {
		nro = nroCancha;
		equipos ++;
		// A 2 equipos les da el mismo nro de cancha
		if (equipos MOD 2 = 0) {
			nroCancha ++;
		}
	}

}

Monitor Equipo [id: 1 .. 4] {
	int cant = 0;
	cond espera;
	int cancha;

	precedure llegóJugador (nroCancha: out in) {
		cant ++;
		if (cant == 5) {
			signal_ all (espera);
			AdministradorCanchas.asignarCancha(cancha);
		}
		else wait (espera);
		nroCancha = cancha;
	}
}


Monitor Cancha [id: 1 .. 2] { 
	int cant = 0;
	cond espera, inicio;

	Procedure llegada () { 
		cant ++;
		if (cant == 10) signal (inicio);
		wait (espera);
	}

	Procedure Iniciar () { 
		if (cant < 10) wait (inicio);
	}

	Procedure Terminar () { 
		signal_all(espera);
	}
}


process Jugador [id: 1 ..20]  {
	int nroEquipo = DarEquipo()
	int nroCancha;

	Equipo[nroEquipo].llegóJugador(nroCancha);

	Cancha[nroCancha].llegada();
}

process Partido [id: 1 .. 2] {
	Cancha[id].iniciar()
	Delay (50 minutos)
	Cancha[id].finalizar()
}




8. Se debe simular una maratón con C corredores donde en la llegada hay UNA máquina
expendedoras de agua con capacidad para 20 botellas. 
Además, existe un repositor encargado de reponer las botellas de la máquina. 
Cuando los C corredores han llegado al inicio comienza la carrera. 
Cuando un corredor termina la carrera se dirige a la máquina expendedora, espera su turno (respetando el orden de llegada), saca una botella y se retira. 
Si encuentra la máquina sin botellas, le avisa al repositor para que cargue nuevamente la máquina con 20 botellas; espera a que se haga la recarga; saca una botella y se retira. Nota: mientras se reponen las botellas se debe permitir que otros corredores se encolen.

Monitor Maratón {
    cant = 0;
    cond espera;

    procedure llegada () {
   	 cant ++;
   	 if (cant == C) {
   		 signal_all (espera)
   	 }
   	 Else wait (espera)
    }
}

Monitor Fila {
	cond espera;
	int esperando = 0;
	boolean libre = true;
	
	procedure hacerFila() {
		if (not libre)  {
			esperando ++;
			wait (espera)
		}
		else libre = true;
	}
	
	procedure irmeDeLaFila() {
		if (esperando > 0) {
			esperando --;
			signal (espera);
		}
		else libre = true;
	}
}


Monitor Máquina {
	cola botellas
	bool avisado = false; 
	cond repositor;
	cond siguiente; 
	
	procedure tomarBotella(botella: out botella) {
		if (botellas.empty()) {
			signal (repositor)
			avisado = true;
			wait (siguiente)
		}
		pop(botellas,botella);
	}
	
	procedure reponer() {
		int i;
		
		if (not avisado) --> wait (repositor)
	
		for i = 1 .. 20 {
			push (botellas,botella);
		}
		
		avisado = false
		signal (siguiente)
	}
}


process Corredor [id: 1 .. C] {
    botella;

    Maratón.llegada();
    // realiza la carrera
    
    Fila.hacerFila()
    Maquina.tomarBotella(botella);
    Fila.irmeDeLaFila()
}

process Repositor {
	while (true) {
		Máquina.reponer();
	}
}

