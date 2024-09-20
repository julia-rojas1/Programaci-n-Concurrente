### PMA (2021)
Resolver con PASAJE DE MENSAJES ASINCRÓNICOS (PMA) el siguiente problema. Se debe simular la atención en un banco con 3 cajas para atender a N clientes que pueden ser especiales (son las embarazadas y los ancianos) o regulares. Cuando el cliente llega al banco se dirige a la caja con menos personas esperando y se queda ahí hasta que lo terminan de atender y le dan el comprobante de pago. Las cajas atienden a las personas que van a ella de acuerdo al orden de llegada pero dando prioridad a los clientes especiales; cuando terminan de atender a un cliente le debe entregar un comprobante de pago. Nota: maximizar la concurrencia.


```java
chan SolicitarCaja(int);
chan LiberarCaja(int);
chan Pedido();
chan RecibirNroCaja[N](int);
chan Atención[3]();
chan AtenciónEspecial[3](int);
chan AtenciónRegular[3](int);
chan Comprobante[N](String);

process Cliente[id: 1 .. N] {
    int miPrioridad = getPrioridad() // embarazada o anciano = 1, regular = 0
    int nroCaja;
    String comprobante;

    send SolicitarCaja(id);
    send Pedido()
    receive RecibirNroCaja[id](nroCaja);


    if (miPrioridad = 1) {
        send AtenciónEspecial[nroCaja](id);
    }
    else {
        send AtenciónRegular[nroCaja](id);
    }
    send Atención[nroCaja]();



    receive Comprobante[id](comprobante);
    send LiberarCaja(nroCaja);
    send Pedido();
}

process Caja[id: 1 .. 3] {
    int idCliente;
    String comprobante;
    while (true) {
        receive Atención[id]();
        if (empty(AtenciónPrioridad)) {
            receive AtenciónRegular[id](idCliente);
        }
        else {
            receive AtenciónEspecial[id](idCliente);
        }
        comprobante = Atender(idCliente);
        send Comprobante[idCliente](comprobante);
    }
}

process Coordinador {
    int persXcaja[3] = ([3] 0);
    int idCliente, idCaja;

    while (true) {
        receive Pedido();
        if (empty(LiberarCaja)) {
            receive SolicitarCaja(idCliente);

            idCaja = min(persXcaja);
            persXcaja[idCaja]++;

            send RecibirNroCaja[idCliente](idCaja);
        }
        else {
            receive LiberarCaja(idCaja);
            persXcaja[idCaja]--;
        }
    }
}

```


### PMA (2021)
Resolver con PMA el siguiente problema. Se debe modelar el funcionamiento de una casa de venta de repuestos automotores, en la que trabajan V vendedores y que debe atender a C clientes. El modelado debe considerar que: (a) cada cliente realiza un pedido y luego espera a que se lo entreguen; y (b) los pedidos que hacen los clientes son tomados por cualquiera de los vendedores. Cuando no hay pedidos para atender, los vendedores aprovechan para controlar el stock de los repuestos (tardan entre 2 y 4 minutos para hacer esto). Nota: maximizar la concurrencia.

```java
chan Libre(int);
chan Siguiente[V](int,string);
chan EnviarPedido(int,string);
chan RecibirPedido[C](string);

process Admin {
    int idVendedor, idCliente;
    String pedido;

    while (true) {
        receive Libre(idVendedor);
        if (empty(EnviarPedido)) {
            pedido = "-1";
            idCliente = -1;
        }
        else {
            receive EnviarPedido(idCliente,pedido);
        }
        send Siguiente[idVendedor](idCliente,pedido)

    }
}


process Vendedor [id: 1 .. V] {
    int idCliente;
    String pedido;

    while (true) {      
        send Libre(id);
        receive Siguiente[id](idCliente,pedido);
        if (pedido <> "-1") {
            pedido = resolverPedido();
            send RecibirPedido[idCliente](pedido);
        }
        else {
            delay (random(2,4));
            // Controlan stock de los repuestos
        }
    }
}

process Cliente [id: 1 .. C] {
    String pedido = generarPedido();

    send EnviarPedido(id,pedido);
    receive RecibirPedido[id](pedido);
}
```





#### PMS (2.recuperatorio) 
Resolver con Pasaje de Mensajes Sincrónicos (PMS) el siguiente problema. En un torneo de programación hay 1 organizador, N competidores y S supervisores. El organizador comunica el desafío a resolver a cada competidor. Cuando un competidor cuenta con el desafío a resolver, lo hace y lo entrega para ser evaluado. A continuación, espera a que alguno de los supervisores lo corrija y le indique si está bien. En caso de tener errores, el competidor debe corregirlo y volver a entregar, repitiendo la misma metodología hasta que llegue a la solución esperada. Los supervisores corrigen las entregas respetando el orden en que los competidores van entregando. Nota: maximizar la concurrencia y no generar demora innecesaria.

```java

process Organizador {
    for i = 1 .. N {
        desafíos[i] = desafíoPasaCompetidor();
    }

    while (true) {
        do
            * Competidor[*]?SolicitarDesafio(idCompetidor) -> {
                Competidor[idCompetidor]!EnviarDesafío(desafíos[idCompetidor]);
            }
            * Competidor[*]?DesafíoResuelto(resolución,idCompetidor) -> {  // Mejor utilizar un proceso admin que se encargue de la comunicación e/ supervisores y competidores
                push (desafíosResueltos,(resolución,idCompetidor));
            }
            * not empty(desafíosResueltos); Supervisor[*]?Libre(idSupervisor) -> {
                pop (desafíosResueltos,(resolución,idCompetidor));
                Supervisor[idSupervisor]!ResoluciónDesafío(resolución,idCompetidor);
            }

        od
    }
}

process Competidor[id: 1 .. N] {
    String desafío;

    Organizador!SolicitarDesafio(id);
    Organizador?EnviarDesafío(desafío);

    boolean finalizado = false;
    String corrección = "";
    String resoluciónDesafío = "";
    while (not finalizado) {s
        resoluciónDesafío = resolver(desafío,resoluciónDesafío, corrección);

        Organizador!DesafíoResuelto(resoluciónDesafío,id);
        Supervisor[*]?Corrección(corrección);
        if (corrección = "excelente") {
            finalizado = true;
        }
    }

}

process Supervisor[id 1 .. S] {
    while (true) {
        Coordinador!Libre(id);
        Coordinador?ResoluciónDesafío(resolución,idCompetidor);

        corrección = corregir(resolución);

        Competidor[idCompetidor]!Corrección(corrección);
    }
}
```

(3.SegundoRecuperatorio)
Resolver con Pasaje de Mensajes Sincrónicos (PMS) el siguiente problema. En un comedor estudiantil hay un horno microondas que debe ser usado por E estudiantes de acuerdo con el orden de llegada. Cuando el estudiante accede al horno, lo usa y luego se retira para dejar al siguiente. Nota: cada Estudiante una sólo una vez el horno.


5. Resolver con PMA el siguiente problema. En un gimnasio hay tres Maquinas iguales que pueden ser utilizadas para hacer ejercicio o rehabilitación. Hay E personas que quieren usar cualquiera de esas Maquinas para hacer ejercicio, y R personas que las quieren usar para hacer rehabilitación. Siempre tienen prioridad aquellas que la quieran usar para realizar rehabilitación. Cuando una persona toma una Maquina la usa por 10 minutos y se retira.   

```java
process Maquina[id: 1 .. 3] {
    while (true) {
        Admin!Libre(id);
        do
            * PersonaEjercicio[*]?Liberada();
            * PersonaRehabilitacion[*]?Liberada();
        od
    }

}

process PersonaEjercicio[id: 1 .. E] {
    Admin!SolicitarMaquinaE(id);
    Admin?AsignarMaquinaE(idMaquina);
    // Usa la Maquina por 10 minutos
    Maquina[idMaquina]!Liberada();
}

process PersonaRehabilitacion[id: 1 .. R] {
    Admin!SolicitarMaquinaR(id);
    Admin?AsignarMaquinaR(idMaquina);
    // Usa la Maquina por 10 minutos
    Maquina[idMaquina]!Liberada();
}

process Admin{
    while (true) {
        do
            * not empty(SolicitarMaquinaR); Maquina[*]?Libre(idMaquina) -> {
                PersonaRehabilitacion[*]?SolicitarMaquinaR(idPersona);
                PersonaRehabilitacion[idPersona]!AsignarMaquinaR(idMaquina);
            } 
            * empty(SolicitarMaquinaR) && not empty(SolicitarMaquinaE); Maquina[*]?Libre(idMaquina) ->  {
                PersonaEjercicio[*]?SolicitarMaquinaE(idPersona);
                PersonaEjercicio[idPersona]!AsignarMaquinaE(idMaquina);
        od
    }
}


```
