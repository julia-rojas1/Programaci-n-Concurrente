### Ejercicio 1
Suponga que existe un antivirus distribuido que se compone de R procesos robots Examinadores y 1 proceso Analizador. 
Los procesos Examinadores están buscando continuamente posibles sitios web infectados; cada vez que encuentran uno avisan la dirección y luego continúan buscando. 
El proceso Analizador se encarga de hacer todas las pruebas necesarias con cada uno de los sitios encontrados por los robots para determinar si están o no infectados. 

#### Inciso A
Analice el problema y defina qué procesos, recursos y comunicaciones serán necesarios/convenientes para resolver el problema.

#### Inciso B
Implemente una solución con PMS.

```java
process Examinador[id: 1 .. R] {
    Text sitioInfectado;
    while (true) {
        sitioInfectado = buscaSitioInfectado();
        Admin!reporte(sitioInfectado);
    }
    
}

process Analizador {
    boolean infectado;
    while (true) {
        Admin!libre();
        Admin?reporte(sitioInfectado);
        infectado = realizaPruba(sitioInfectado);
    }
}

process Admin {
    Cola buffer;
    Text sitioInfectado;

    while (true) {
        do 
            □ Examinador?reporte(sitioInfectado) -> {
                push(buffer,sitioInfectado);
            }
            □ not empty(buffer); Analizador?libre() -> {
                pop(buffer,sitioInfectado)
                Analizador!reporte(sitioInfectado)
            } 
        od
    }
}

```

-------------------------------------------------------------------------------------------------
### Ejercicio 2

En un laboratorio de genética veterinaria hay 3 empleados. 
El primero de ellos continuamente prepara las muestras de ADN; cada vez que termina, se la envía al segundo empleado y vuelve a su trabajo. 
El segundo empleado toma cada muestra de ADN preparada, arma el set de análisis que se deben realizar con ella y espera el resultado para archivarlo. 
Por último, el tercer empleado se encarga de realizar el análisis y devolverle el resultado al segundo empleado.

```java
process Admin {
    Cola buffer;
    String muestra
    do
        □ Empleado1?reporteMuestra(muestra) -> {
            push(bufferMuestras,muestra);
        }
        □ not empty(buffer); Empleado2?Libre() -> {
            pop(bufferMuestras,muestra);
            Empleado2!solicitarMuestra(muestra)
        }
    od 
}

process Empleado1 {
    String muestra;
    while (true) {
        // Genera muestra de ADN
        muestra = generarMuestraADN();
        // La envía al Empleado2
        Admin!reporteMuestra(muestra)
    }
}

process Empleado2 {
    while (true) {
        // Recibe muestra de ADN
        Admin!Libre()
        Admin?solicitarMuestra(muestra)

        // Arma set para análisis
        String setAnalisis = ArmarSetPara(muestra);
        Empleado3!ReporteSetAnalisis(setAnalisis,muestra);
        
        // Espera resultado para archivarlo
        Empleado2?ReporteAnalisis(analisis);
        archivar(analisis);
    }
}

process Empleado3 {
    while (true) {
        Empleado2?ReporteSetAnalisis(setAnalisis,muestra);
        String analisis = Analizar(muestra,setAnalisis);
        Empleado2!ReporteAnalisis(analisis);
    }
}

```
-------------------------------------------------------------------------------------------------
### Ejercicio 3

En un examen final hay N alumnos y P profesores. Cada alumno resuelve su examen, lo entrega y espera a que alguno de los profesores lo corrija y le indique la nota. Los profesores corrigen los exámenes respetando el orden en que los alumnos van entregando.
a) Considerando que P=1.
b) Considerando que P>1.
c) Ídem b) pero considerando que los alumnos no comienzan a realizar su examen hasta que todos hayan llegado al aula.
Nota: maximizar la concurrencia y no generar demora innecesaria.


#### Inciso A
Considerando que P=1.
```java

process Alumno[id: 1 .. N] {
    String examen = resolverExamen();
    Admin!entregarExamen(examen,id);
    Profesor?nota(nota)
}

process Profesor {
    for i = 1 .. N {
        Admin!Libre();    
        Admin?entregarExamen(examen,id);

        nota = corregir(examen);
        Alumno[id]!nota(nota);
    }
}

process Admin {
    Cola examenes;
    String examen;
    int id;
    do
        * Alumno[*]?entregarExamen(examen,id) -> {
            push (examenes,(examen,id));
        }
        * not empty(examenes); Profesor?Libre() -> {
            pop (examenes,(examen,id));
            Profesor!entregarExamen((examen,id));
        }
    od
}

--------------------------viejo--------------------------------------------
/* process Alumno[id: 1 .. N] {
    String examen = resolverExamen();

    Profesor!entregarExamen(examen,id);
    Profesor?nota(nota)
}

process Profesor {
    for i = 1 .. N {    
        Alumno?entregarExamen(examen,id);
        //TODO: se enconlan en orden o la selección es no determinística?

        nota = corregir(examen);
        Alumno[id]!nota(nota);
    }
} */

```

#### Inciso B
Considerando que P>1
```java

process Alumno[id: 1 .. N] {
    String examen = resolverExamen();
    Admin!entregarExamen(examen,id);
    Profesor[*]?nota(nota)
}

process Profesor[id: 1 .. P] {
    for i = 1 .. N {
        Admin!Libre(id);    
        Admin?entregarExamen(examen,idAlum);

        nota = corregir(examen);
        Alumno[idAlum]!nota(nota);
    }
}

process Admin {
    Cola examenes;
    String examen;
    int id;
    do
        * Alumno[*]?entregarExamen(examen,id) -> {
            push (examenes,(examen,id));
        }
        * not empty(examenes); Profesor[*]?Libre(idProfe) -> {
            pop (examenes,(examen,id));
            Profesor[idProfe]!entregarExamen((examen,id));
        }
    od
}

```

### Inciso C
Ídem b) (P>1) pero considerando que los alumnos no comienzan a realizar su examen hasta que todos hayan llegado al aula.
Nota: maximizar la concurrencia y no generar demora innecesaria.

```java

process Alumno[id: 1 .. N] {
    Admin!Llegada();
    Admin!Comienzo();

    String examen = resolverExamen();
    Admin!entregarExamen(examen,id);
    Profesor[*]?nota(nota)
}

process Profesor[id: 1 .. P] {
    for i = 1 .. N {
        Admin!Libre(id);    
        Admin?entregarExamen(examen,idAlum);

        nota = corregir(examen);
        Alumno[idAlum]!nota(nota);
    }
}

process Admin {
    Cola examenes;
    String examen;
    int id, i;

    for i = 1 .. N {
        Alumno[*]?Llegada();
    }
    // Hasta que no llegaron N alumnos no puede recibir la solicitud de comenzar
    for i = 1 .. N {
        Alumno[*]?Comienzo();
    }


// separar en otro proceso a partir de aca

    do
        * Alumno[*]?entregarExamen(examen,id) -> {
            push (examenes,(examen,id));
        }
        * not empty(examenes); Profesor[*]?Libre(idProfe) -> {
            pop (examenes,(examen,id));
            Profesor[idProfe]!entregarExamen((examen,id));
        }
    od
}

```
-------------------------------------------------------------------------------------------------
### Ejercicio 4

4. En una exposición aeronáutica hay un simulador de vuelo (que debe ser usado con exclusión mutua) y un empleado encargado de administrar su uso. Hay P personas que esperan a que el empleado lo deje acceder al simulador, lo usa por un rato y se retira. El empleado deja usar el simulador a las personas respetando el orden de llegada. Nota: cada persona usa sólo una vez el simulador.

```java

process Empleado {
    boolean libre = true;
    Cola fila;
    int esperando = 0; 
    while (true) {
        do 
            * Persona[*]?Llegada(idPersona) -> {
                if (libre) {
                    Persona[idPersona]!AccesoAlSimulador()
                    libre = false
                }
                else {
                    push (fila, idPersona);
                    esperando ++;
                }
            }

            * Persona[*]?Salida -> {
                if (esperando > 0) {
                    esperando --;
                    pop (fila, idPersona);
                    Persona[idPersona]!AccesoAlSimulador()
                }
                else {
                    libre = true;
                }
            }
        od
    }
}


// SI NO IMPORTA EL ORDEN SE PUEDE RESOLVER ASI
while (true) {
        do 
            * libre ;Persona[*]?Llegada(idPersona) -> {
                Persona[idPersona]!AccesoAlSimulador()
                libre = false
                
            }

            * Persona[*]?Salida -> {
                   libre = true;
                
        od
    }


process Persona [id: 1 .. P] {
    Empleado!Llegada(id);
    Empleado?AccesoAlSimulador();
    // usa simulador
    Empleado!Salida();
}

```




-------------------------------------------------------------------------------------------------
### Ejercicio 5
5. En un estadio de fútbol hay una máquina expendedora de gaseosas que debe ser usada por E Espectadores de acuerdo al orden de llegada. Cuando el espectador accede a la máquina en su turno usa la máquina y luego se retira para dejar al siguiente. Nota: cada Espectador una sólo una vez la máquina.

```java
process Espectador[id: 1 .. E] {
    
}


```