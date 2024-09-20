1. Resolver con SEMÁFOROS el siguiente problema. 
En una fábrica de muebles trabajan 50 empleados. 
A llegar, los empleados forman 10 grupos de 5 personas cada uno, de acuerdo al orden de llegada (los 5 primeros en llegar forman el primer grupo, los 5 siguientes el segundo grupo, y así sucesivamente).
Cuando un grupo se ha terminado de formar, todos sus integrantes se ponen a trabajar. 
Cada grupo debe armar M muebles (cada mueble es armado por un solo empleado); mientras haya muebles por armar en el grupo los empleados los irán resolviendo (cada mueble es armado por un solo empleado). Nota: Cada empleado puede tardar distinto tiempo en armar un mueble. Sólo se pueden usar los procesos “Empleado”, y todos deben terminar su ejecución. Maximizar la concurrencia.



process Empleado [id: 1 .. 50] {
	// llegan 5 y forman un grupo
	// Cada grupo debe hacer M muebles
	// hace mueble
	
}











































2. Resolver con MONITORES el siguiente problema. En un comedor estudiantil hay un horno microondas que debe ser usado por E
estudiantes de acuerdo con el orden de llegada. Cuando el estudiante accede al horno, lo usa y luego se retira para dejar al
siguiente. Nota: cada Estudiante una sólo una vez el horno; los únicos procesos que se pueden usar son los “estudiantes”.
