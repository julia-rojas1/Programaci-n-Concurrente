# PMA
chan nombrecanal (tipoDato)
chan nombrearreglo[1..m](tipoDato)

```c
    send nombrecanal(mensaje)
    send nombrearreglo[i](mensaje)
/* DUDA: SE PUEDE HACER UN CANAL DONDE SOLO SE SINCRONICE? (sin mandar datos): SIII */
/* DUDA: LOS PROCESOS DEBEN TERMINAR ALUNA VEZ?? COMO? solo si lo piden*/
    receive nombrecanal (Variables para el mensaje)
    receive nombrearreglo[i](Variables para el mensaje)
```

## Ejercicio 1
Suponga que N clientes llegan a la cola de un banco y que serán atendidos por sus empleados.

Analice el problema y defina qué procesos, recursos y comunicaciones serán necesarios/convenientes para resolver el problema.
Luego, resuelva considerando las siguientes situaciones:

### Inciso a
Existe un único empleado, el cual atiende por orden de llegada.

```java
chan SolicitudAtencion(int)
chan Atencion[N]()

Process Cliente[id:1..N]{
    send SolicitudAtencion(id) //manda solicitud de atención
    receive Atencion[id]() //espera a que lo atiendan
    //lo atienden
    receive Retirarse[id]()
}

Process Empleado{
    int idCliente;
    for i in 1..N{
        receive SolicitudAtencion(idCliente)
        send Atencion[idCliente]()
        //atiende al cliente
        send Retirarse[idCliente]()
    }
}

```

### Inciso b
Ídem a) pero considerando que hay 2 empleados para atender, ¿qué debe modificarse en la solución anterior?

```java
chan SolicitudAtencion(int)
chan Atencion[N]()

Process Cliente[id:1..N]{
    send SolicitudAtencion(id) //manda solicitud de atención
    receive Atencion[id]() //espera a que lo atiendan
    //lo atienden
    receive Retirarse[id]()
}

Process Empleado[1..2]{
    int idCliente;
    while true {
        receive SolicitudAtencion(idCliente)
        send Atencion[idCliente]()
        //atiende al cliente
        send Retirarse[idCliente]()
    }
}

```

### Inciso c
Ídem c) pero considerando que, si no hay clientes para atender, los empleados realizan tareas administrativas durante 15 minutos. ¿

```java
chan SolicitudAtencion(int)
chan Atencion[N]()

chan TomarAtencion(int)
chan SiguienteAtencion[2](int)

Process Cliente[id:1..N]{
    send SolicitudAtencion(id) //manda solicitud de atención
    receive Atencion[id]() //espera a que lo atiendan
    //lo atienden
    receive Retirarse[id]()
}

Process Coordinador{
    int idCliente;
    int idEmpleado
    while true {
        receive TomarAtencion(idEmple) //espero a que un empleado este listo para atender un cliente
        if ( empty (SolicitudAtencion)){ //si no hay solicitudes pendientes de atencion de clientes
            idCliente = -1 //le digo que no hay ningun cliente para atender
        }else{
            receive SolicitudAtencion(idCliente) // le seteo el id del cliente
        }
        send SiguienteAtencion[idEmple](idCliente) //le respondo al empleado
    }/* DUDA: ESTARIA MAL HACER EL SEND DENTRO DEL IF Y DEL ELSE?? NO*/
}

Process Empleado[id:1..2]{
    int idCliente;
    while true {
        send TomarAtencion(id)
        receive SiguienteAtencion[id](idCliente)
        if (idCliente != -1){
            send Atencion[idCliente]()
            //atiende al cliente
            send Retirarse[idCliente]()
        }else{
            delay(15 minutos) //realizan tareas administrativas
        }

    }
}

```


## Ejercicio 2
Se desea modelar el funcionamiento de un banco en el cual existen 5 cajas para realizar pagos. Existen P clientes que desean hacer un pago. Para esto, cada una selecciona la caja donde hay menos personas esperando; una vez seleccionada, espera a ser atendido. En cada caja, los clientes son atendidos por orden de llegada por los cajeros. Luego del pago, se les entrega un comprobante. Nota: maximizando la concurrencia.


```java
chan ElejirCaja(int)
chan RecibirCaja[P](int)

chan Atencion[N]()
chan Retirarse[N](string)

chan FinAtencion(int)

Process Cliente[id:1..P]{
    int idCaja;
    int montoPago = miMonto()
    send ElejirCaja(id) //manda solicitud de caja
    send hayPedido() /* PARA EVITAR BUSY WAITING */

    receive RecibirCaja[id](idCaja) //espera que le indiquen la caja con menos personas

    send SolicitarAtencion[idCaja](id,montoPago) //solicita la atencion en la caja
    receive Atencion[id]() //espera a que lo atiendan en la caja
    //lo atienden
    receive Retirarse[id](comprobante)
}

Process Coordinador{
    int idCliente;
    int idCaja;
    int[] cantEsperandoCajas[5]
    while true {
        /* DUDA: ES LA UNICA SOLUCIÓN? BUSY WAITING? NOOO */
        receive hayPedido() /* PARA EVITAR BUSY WAITING */
        if (not empty(FinAtencion)) -> {
            receive FinAtencion(idCaja)
            cantEsperandoCajas[idCaja]--
        }
        else {
            receive ElejirCaja(idCliente)
            minCaja = min(cantEsperandoCajas) //devuelve la caja con menos cola
            cantEsperandoCajas[minCaja]++
            send ElejirCaja[idCliente](minCaja) //le manda al cliente la caja con menos cola
        }
    }
}

Process Empleado[id:1..5]{
    int idCliente;
    int montoPago;
    while true {
        receive SolicitarAtencion[id](idCliente,montoPago) //espera al prox cliente y obtiene su id y el monto de pago
        send Atencion[idCliente]()
        
        String comprobante = depositarPago(monto)

        send Retirarse[idCliente](comprobante)
        send FinAtencion(id) //aviso al coordinador que terminé de atender a un cliente
        send hayPedido() /* PARA EVITAR BUSY WAITING */
    }
}

```


## Ejercicio 3: casa de comida rápida
Se debe modelar el funcionamiento de una casa de comida rápida, en la cual trabajan 2 cocineros y 3 vendedores, y que debe atender a C clientes.

El modelado debe considerar que:
- Cada cliente realiza un pedido y luego espera a que se lo entreguen.
- Los pedidos que hacen los clientes son tomados por cualquiera de los vendedores y se lo pasan a los cocineros para que realicen el plato. Cuando no hay pedidos para atender, los vendedores aprovechan para reponer un pack de bebidas de la heladera (tardan entre 1 y 3 minutos para hacer esto).
- Repetidamente cada cocinero toma un pedido pendiente dejado por los vendedores, lo cocina y se lo entrega directamente al cliente correspondiente.
Nota: maximizar la concurrencia.


```java
chan RealizarPedido(int,Pedido)
chan EnviarComida[1..C]()
chan EnviarPedido[1..3](int,Pedido)

Process Cliente[id:1..C]{
    Comida comida
    Pedido pedido = pensarPedido()
    send RealizarPedido(id,pedido)
    receive EnviarComida[id](comida)
}

Process Coordinador{
    int idVendedor
    int idComprador
    Pedido pedido
    while true {
        receive SolicitarPedido(idVendedor)
        if empty(RealizarPedido){
            send EnviarPedido[idVendedor](-1,null)
        }
        else{
            receive RealizarPedido(idComprador,pedido)
            send EnviarPedido[idVendedor](idComprador,pedido)
        }
    }
}

Process Vendedor[id:1..3]{
    int idComprador
    Pedido pedido
    while true {
        send SolicitarPedido(id)
        receive EnviarPedido[id](idComprador,pedido)
        if (idComprador == -1){
            delay(random(1,3)) //repone pack de bebidas en heladera
        }else{
            send EnviarPedidoACocinar(idComprador,pedido)
        }
    }
}

Process Cocinero[id:1..2]{
    int idComprador
    Pedido pedido
    while true{
        receive EnviarPedidoACocinar(idComprador,pedido)
        Comida comida = cocinar(pedido)
        send EnviarComida[idComprador](comida)
    }
}


```



## Ejercicio 4: locutorio
Simular la atención en un locutorio con 10 cabinas telefónicas, el cual tiene un empleado que se encarga de atender a N clientes.
Al llegar, cada cliente espera hasta que el empleado le indique a qué cabina ir, la usa y luego se dirige al empleado para pagarle. 
El empleado atiende a los clientes en el orden en que hacen los pedidos, pero siempre dando prioridad a los que terminaron de usar la cabina.
A cada cliente se le entrega un ticket factura.

Nota: maximizar la concurrencia; suponga que hay una función Cobrar() llamada por el empleado que simula que el empleado le cobra al cliente.
```java

chan Llegadas(int)
chan Atencion[1..N](int)
chan Pedido()
chan PagoCabina(int,int,int)
Process Cliente[id:1..N]{
    int idCabina;
    Ticket ticket
    send Llegadas(id)
    send Pedido()
    receive Atencion[id](idCabina)
    int monto = usarCabina(idCabina)
    send PagoCabina(id,monto,idCabina)
    send Pedido()
    receibe FinPago[id](ticket)
}
/* Se puede usar cola de prioridad de alguna forma? */
Process Empleado{
    Cola cabinasLibres = {1,2,3,4,5,..,10}
    int idCliente,idCabina,monto
    while true{
        receive Pedido()
        if notEmpty(PagoCabina){
            receive PagoCabina(idCliente,monto,idCabina)
            cabinasLibres.push(idCabina)
            Ticket ticket = Cobrar(monto)
            send FinPago[idCliente](ticket)
            while Empty(PagoCabina) and cabinasLibres.notEmpty() and pendientes.notEmpty(){
                //si no hay pagos pendientes y hay clientes esperando sus cabinas y hay cabinas disponibles
                idCliente = pendientes.pop()
                idCabina = cabinasLibres.pop()
                send Atencion[idCliente](idCabina)
            }
        }else{
            receive Llegadas(idCliente)
            if cabinasLibres.notEmpty(){ //si hay cabinas libres
                idCabina= cabinasLibres.pop()
                send Atencion[idCliente](idCabina)
            }
            else{
                pendientes.push(idCliente) //si no hay cabinas libres, meto al cliente en la cola de clientes que están esperando
            }
        } 
    }
}



while true{
        atenderCobro=false;
        receive Pedido()
        if notEmpty(PagoCabina){
            receive PagoCabina(idCliente,monto,idCabina)
            atenderCobro=true
           
        }else{
            receive Llegadas(idCliente)
            idCabina= cabinasLibres.pop()
            send Atencion[idCliente](idCabina)

            if cabinasLibres.Empty(){ //NO hay MAS cabinas libres
                receive PagoCabina(idCliente,monto,idCabina)
                receive Pedido()
                atenderCobro=true
            }
            
        } 
        if(atenderCobro)
            cabinasLibres.push(idCabina)
            Ticket ticket = Cobrar(monto)
            send FinPago[idCliente](ticket)




CON BUSY WAITING
        if(not empty(PagoCabina) )
            receive PagoCabina(idCliente,monto,idCabina)
             cabinasLibres.push(idCabina)
            Ticket ticket = Cobrar(monto)
            send FinPago[idCliente](ticket)

        * empty(PagoCabina) and not empty (Llegadas)
            receive Llegadas(idCliente)
            idCabina= cabinasLibres.pop()
            send Atencion[idCliente](idCabina)



```

## Ejercicio 5
Resolver la administración de las impresoras de una oficina. Hay 3 impresoras, N usuarios y 1 director.
Los usuarios y el director están continuamente trabajando y cada tanto envían documentos a imprimir.

Cada impresora, cuando está libre, toma un documento y lo imprime, de acuerdo con el orden de llegada, pero siempre dando prioridad a los pedidos del director. 

Nota: los usuarios y el director no deben esperar a que se imprima el documento.

```java
/* Acá tampoco se puede usar cola?  */
Process Usuario[id:1..N]{
    while true{
        //trabajar
        documento = new Documento();
        send EnviarAImprimirDesdeUsuario(documento);
    }
}

Process Director{
    while true{
        //trabajar
        documento = new Documento();
        send EnviarAImprimirDesdeDirector(documento);
    }
}

/* TODO: continuar */

Process Admin{

}

Process Impresora[id:1..3]{

}

```






# PMS

Envío(!):la operación es bloqueante y sincrónica,se demora hasta que la recepción haya terminado.
- destino!port (mensaje)
- destino[i]!port (mensaje)

Recepción (?): la operación es bloqueante y sincrónica.
- origen?port (variable)
- origen[i]?port (variable)
- origen[*]?port (variable)


Evaluación de una guarda:
- **Exito**: la condición booleana es Verdadera (o no la tiene) y la
comunicación se puede realizar sin producir demora (el emisor
está esperando hacer la comunicación).
- **Fallo**: la condición booleana es Falsa, sin importar lo que ocurra
con la sentencia de comunicación.
- **Bloqueo**: la condición booleana es Verdadera (o no la tiene) pero
la comunicación NO se puede realizar sin producir demora (el
emisor aún no llegó a la sentencia de envío).



## Ejercicio 1
Suponga que existe un antivirus distribuido que se compone de R procesos robots Examinadores y 1 proceso Analizador.
Los procesos Examinadores están buscando continuamente posibles sitios web infectados; cada vez que encuentran uno avisan la dirección y luego continúan buscando.
El proceso Analizador se encarga de hacer todas las pruebas necesarias con cada uno de los sitios encontrados por los robots para determinar si están o no infectados.

### Inciso a
Analice el problema y defina qué procesos, recursos y comunicaciones serán necesarios/convenientes para resolver el problema.

### Inciso b
Implemente una solución con PMS.

```java
Process Examinador[id: 1..R]{
    while true{
        String sitio = examinar()
        Direccion!envioSitio(sitio)
    }
}

Process Direccion{
    cola buffer
    String sitio
    do Examinador[*]?envioSitio(sitio) -> {buffer.push(sitio)}
    * buffer.notEmpty(); Analizador?pedido() -> {
        sitio = buffer.pop()
        Analizador!envioSitio(sitio)
    }

}

Process Analizador{
    String sitio
    while (true){
        Direccion!pedido()
        Direccion?envioSitio(sitio)
        analizarSitio(sitio)
    }
}

```


## Ejercicio 2

En un laboratorio de genética veterinaria hay 3 empleados. El primero de ellos continuamente prepara las muestras de ADN; cada vez que termina, se la envía al segundo empleado y vuelve a su trabajo.

El segundo empleado toma cada muestra de ADN preparada, arma el set de análisis que se deben realizar con ella y espera el resultado para archivarlo.

Por último, el tercer empleado se encarga de realizar el análisis y devolverle el resultado al segundo empleado.


```java

Process Preparador{ //primer empleado
    while true{
        Muestra m = prepararMuestra();
        MesaMuestras!envioMuestra(m)
    }
}

Process MesaMuestras{
    Muestra m;
    Cola colaMuestras;
    do Preparador?envioMuestra() -> {
        colaMuestras.push(m)
    }
    * colaMuestras.notEmpty(); ArmadorSetAnalisis?pedido() ->{
        m = colaMuestras.pop()
        ArmadorSetAnalisis!envioMuestra(m)
    }
}

Process ArmadorSetAnalisis{ //segundo empleado
    Muestra m
    Resultado res
    while true{
        MesaMuestras!pedido()
        MesaMuestras?envioMuestra(m)
        SetAnalisis set = armarSetAnalisis(m) //arma el set de análisis
        Analizador!envioSetAnalisis(set)
        Analizador?Resultado(res)
        archivarResultado(res)
    }
}

Process Analizador{ //tercer empleado
    SetAnalisis set
    while true{
        ArmadorSetAnalisis?envioSetAnalisis(set)
        Resultado res = analizarSet(set)
        ArmadorSetAnalisis!Resultado(res)
    }
}


```



## Ejercicio 3: alumnos y profes

En un examen final hay N alumnos y P profesores.
Cada alumno resuelve su examen, lo entrega y espera a que alguno de los profesores lo corrija y le indique la nota.
Los profesores corrigen los exámenes respetando el orden en que los alumnos van entregando.


### Inciso a)
Considerando que P=1.
<!-- DUDA: SI NO SE RESPETARA EL ORDEN, NO SE NECESITA PROCESO ADMIN,NO? -->
```java
Process Alumno[id:1..N]{
    Examen examen = resolverExamen()
    Admin!EntregoExamen(id,examen)
    Profesor?EntregoCorreccion(nota)
}

Process Admin{
    Cola cola;
    int idAlumno;
    Examen examen;
    do Alumno[*]?EntregoExamen(idAlumno,examen) -> {
        push(cola,idAlumno,examen)
    }
    * cola.notEmpty();Profesor?PedidoExamen() ->{
        pop(cola,idAlumno,examen)
        Profesor!EnviarExamen(idAlumno,examen)
    }
}

Process Profesor{
    int idAlumno,nota;
    Examen examen
    while true{
        Admin!PedidoExamen()
        Admin?EnviarExamen(idAlumno,examen)
        nota = corregirExamen(examen)
        Alumno[idAlumno]!EntregoCorreccion(nota)
    }
}


```

<!-- DUDA: AUN SI NO SE RESPETARA EL ORDEN, SE NECESITA PROCESO ADMIN, NO? si porq no se sabria a q profesor mandar el examen-->
### Inciso b)
Considerando que P>1.

```java
Process Alumno[id:1..N]{
    Examen examen = resolverExamen()
    Admin!EntregoExamen(id,examen)
    Profesor[*]?EntregoCorreccion(nota)
}

Process Admin{
    Cola cola;
    int idAlumno;
    int idProfesor;
    Examen examen;
    do Alumno[*]?EntregoExamen(idAlumno,examen) -> {
        push(cola,idAlumno,examen)
    }
    * cola.notEmpty();Profesor[*]?PedidoExamen(idProfesor) ->{
        pop(cola,idAlumno,examen)
        Profesor[idProfesor]!EnviarExamen(idAlumno,examen)
    }
}

Process Profesor[id:1..P]{
    int idAlumno,nota;
    Examen examen
    while true{
        Admin!PedidoExamen(id)
        Admin?EnviarExamen(idAlumno,examen)
        nota = corregirExamen(examen)
        Alumno[idAlumno]!EntregoCorreccion(nota)
    }
}


```

### Inciso c)
Ídem b) (P>1) pero considerando que los alumnos no comienzan a realizar su examen hasta que todos hayan llegado al aula.
Nota: maximizar la concurrencia y no generar demora innecesaria.

```java
Process Alumno[id:1..N]{
    Admin!llegoAlumno()
    Admin?comenzarExamen()
    Examen examen = resolverExamen()
    Admin!EntregoExamen(id,examen)
    Profesor[*]?EntregoCorreccion(nota)
}

Process Admin{
    Cola cola;
    int idAlumno;
    int idProfesor;
    Examen examen;
    int cantAlumnos = 0

    for i in 1..N{
        Alumno[*]?LlegoAlumno()
    }
    for i in 1..N do Alumno[i]!comenzarExamen()
    
    do Alumno?EntregoExamen(idAlumno,examen) -> {
        push(cola,idAlumno,examen)
    }
    * cola.notEmpty();Profesor[*]?PedidoExamen(idProfesor) ->{
        pop(cola,idAlumno,examen)
        Profesor[idProfesor]!EnviarExamen(idAlumno,examen)
    }
    
}

Process Profesor[id:1..P]{
    int idAlumno,nota;
    Examen examen
    while true{
        Admin!PedidoExamen(id)
        Admin?EnviarExamen(idAlumno,examen)
        nota = corregirExamen(examen)
        Alumno[idAlumno]!EntregoCorreccion(nota)
    }
}


```

<!-- Otra solución posible? -->

```java
Process Alumno[id:1..N]{
    Admin!llegoAlumno()
    Admin?comenzarExamen()
    Examen examen = resolverExamen()
    Admin!EntregoExamen(id,examen)
    Profesor[*]?EntregoCorreccion(nota)
}

Process Admin{
    Cola cola;
    int idAlumno;
    int idProfesor;
    Examen examen;
    int cantAlumnos = 0
    boolean seguir = true

    /* usar while normal?es mejor q el primero q habia hecho */
    do seguir; Alumno[*]?LlegoAlumno() -> {
        cantAlumnos++
        if (cantAlumnos == N){
            for i in 1..N do Alumno[i]!comenzarExamen()
            seguir = false;
        }
    }


    do Alumno?EntregoExamen(idAlumno,examen) -> {
        push(cola,idAlumno,examen)
    }
    * cola.notEmpty();Profesor[*]?PedidoExamen(idProfesor) ->{
        pop(cola,idAlumno,examen)
        Profesor[idProfesor]!EnviarExamen(idAlumno,examen)
    }
}

Process Profesor[id:1..P]{
    int idAlumno,nota;
    Examen examen
    while true{
        Admin!PedidoExamen(id)
        Admin?EnviarExamen(idAlumno,examen)
        nota = corregirExamen(examen)
        Alumno[idAlumno]!EntregoCorreccion(nota)
    }
}


```

## Ejercicio 4: simulador de vuelo

En una exposición aeronáutica hay un simulador de vuelo (que debe ser usado con exclusión mutua) y un empleado encargado de administrar su uso.
Hay P personas que esperan a que el empleado lo deje acceder al simulador, lo usa por un rato y se retira. 
El empleado deja usar el simulador a las personas respetando el orden de llegada.
Nota: cada persona usa sólo una vez el simulador.

```java

Process Persona[id:1..P]{
    Empleado!Llegar(id)
    Empleado?HabilitarUso()
    //usar simulador
    Empleado!FinalizarUso()
}


Process Empleado{
    int idPersona;
    Cola cola;
    boolean libre = true;
    do Persona[*]?Llegar(idPersona) ->{
        if (libre){
            libre = false
            Persona[idPersona]!HabilitarUso()
        }else{
            cola.push(idPersona)
        }
    }
    * not libre; Persona[*]?FinalizarUso()->{
        if cola.notEmpty(){
            idPersona = cola.pop()
            Persona[idPersona]!HabilitarUso()
        }else{
            libre = true
        }
    }

}

```
En una exposición aeronáutica hay S simuladores de vuelo (que deben ser usado con exclusión mutua) y un empleado encargado de administrar su uso.
Hay P personas que esperan a que el empleado lo deje acceder a un simulador, lo usa por un rato y se retira. 
El empleado deja usar los simuladores a las personas respetando el orden de llegada.
Nota: cada persona usa sólo una vez un simulador.
Pensar con S simuladores (usar intermediario)

```java

Process Persona[id:1..P]{
    Coordinador!Llegar(id)
    Empleado?HabilitarUso(idSimulador)
    usarSimulador(idSimulador)
    Empleado!FinalizarUso(idSimulador)
}

Process Coordinador{
    Cola cola;
    int idPersona;
    do Persona[*]?Llegar(idPersona) ->{
        cola.push(idPersona)
    }
    * Empleado?Pedido() -> {
        cola.pop(idPersona)
        Empleado!EnvioPersona(id)
    }
}


Process Empleado{
    int idPersona;
    Cola colaSimuladores = {1,2,3,4..S};
    boolean libre = true;

    Coordinador!Pedido()
    do colaSimuladores.notEmpty();Coordinador?EnvioPersona(idPersona)->{

    }
    * Coordinador?FinalizarUso(idSimulador)-> {
        colaSimuladores.push(idSimulador)
    }

    while true{
        Coordinador!Pedido()
        Coordinador?EnvioPersona(idPersona)

        
    }
    
    * not libre; Persona[*]?FinalizarUso()->{
        if cola.notEmpty(){
            idPersona = cola.pop()
            Persona[idPersona]!HabilitarUso()
        }else{
            libre = true
        }
    }

}

```

## Ejercicio 5
En un estadio de fútbol hay una máquina expendedora de gaseosas que debe ser usada por E Espectadores de acuerdo al orden de llegada.
Cuando el espectador accede a la máquina en su turno usa la máquina y luego se retira para dejar al siguiente. 
Nota: cada Espectador una sólo una vez la máquina.


```java
/* Igual que el de arriba??? */
Process Espectador{

}

Process Maquina{


}
```