# Ejercicio 1: Puente

Se requiere modelar un puente de un único sentido que soporta hasta 5 unidades de peso.
El peso de los vehículos depende del tipo: cada auto pesa 1 unidad, cada camioneta pesa 2 unidades y cada camión 3 unidades.
Suponga que hay una cantidad innumerable de vehículos (A autos, B camionetas y C camiones).

Analice el problema y defina qué tareas, recursos y sincronizaciones serán necesarios/convenientes para resolver el problema.

## a: misma prioridad
Realice la solución suponiendo que todos los vehículos tienen la misma prioridad.

<!-- Se debe respetar el orden??no -->

```java

Procedure Ejercicio1_a is

Task Puente is 
    entry IngresarAuto()
    entry IngresarCamioneta()
    entry IngresarCamion()
    entry Salir(peso:IN int)
end Puente

Task type Auto
Task type Camioneta
Task type Camion

arrAutos : array (1..A) of Auto
arrCamionetas: array (1..B) of Camioneta
arrCamions: array (1..C) of Camion

Task Body Puente is
    pesoTotal:int
Begin
    pesoTotal = 0
    loop
        SELECT
            accept Salir(peso:IN int) do
                pesoTotal -= peso
            end Salir
        OR
            when (pesoTotal <= 4) =>
                accept IngresarAuto() do
                    pesoTotal += 1
                end IngresarAuto
        OR
            when (pesoTotal <= 3) =>
                accept IngresarCamioneta() do
                    pesoTotal += 2
                end IngresarCamioneta
        OR
            when (pesoTotal <= 2) =>
                accept IngresarCamion() do
                    pesoTotal += 3
                end IngresarCamion
        END SELECT
    end loop
End Puente

Task Body Auto
Begin
    Puente.IngresarAuto()
    //cruzo el puente
    Puente.Salir(1)
End Auto

Task Body Camioneta
Begin
    Puente.IngresarCamioneta()
    //cruzo el puente
    Puente.Salir(2)
End Auto

Task Body Camion
Begin
    Puente.IngresarCamion()
    //cruzo el puente
    Puente.Salir(3)
End Auto

Begin
    null
End Ejercicio1_a


```


## b: camion mas prioridad
Modifique la solución para que tengan mayor prioridad los camiones que el resto de los vehículos

```java

Procedure Ejercicio1_a is

Task Puente is 
    entry IngresarAuto()
    entry IngresarCamioneta()
    entry IngresarCamion()
    entry Salir(peso:IN int)
end Puente

Task type Auto
Task type Camioneta
Task type Camion

arrAutos : array (1..A) of Auto
arrCamionetas: array (1..B) of Camioneta
arrCamions: array (1..C) of Camion

Task Body Puente is
    pesoTotal:int
Begin
    pesoTotal = 0
    loop
        SELECT
            accept Salir(peso:IN int) do
                pesoTotal -= peso
            end Salir
        OR
            when (pesoTotal <= 4) and (IngresarCamion´count==0) => /* Esto es lo único que cambie */
                accept IngresarAuto() do
                    pesoTotal += 1
                end IngresarAuto
        OR
            when (pesoTotal <= 3) =>
                accept IngresarCamioneta() and (IngresarCamion´count==0) do /* Esto es lo único que cambie */
                    pesoTotal += 2
                end IngresarCamioneta
        OR
            when (pesoTotal <= 2) =>
                accept IngresarCamion() do
                    pesoTotal += 3
                end IngresarCamion
        END SELECT
    end loop
End Puente

Task Body Auto
Begin
    Puente.IngresarAuto()
    //cruzo el puente
    Puente.Salir(1)
End Auto

Task Body Camioneta
Begin
    Puente.IngresarCamioneta()
    //cruzo el puente
    Puente.Salir(2)
End Auto

Task Body Camion
Begin
    Puente.IngresarCamion()
    //cruzo el puente
    Puente.Salir(3)
End Auto

Begin
    null
End Ejercicio1_b


```


# Ejercicio 2: banco
Se quiere modelar el funcionamiento de un banco, al cual llegan clientes que deben realizar un pago y retirar un comprobante.
Existe un único empleado en el banco, el cual atiende de acuerdo con el orden de llegada.
Los clientes llegan y si esperan más de 10 minutos se retiran sin realizar el pago.

```java

Procedure Ejercicio2 is 

/* Declaración de tasks */

Task Empleado is 
    entry RecibirPago(monto:IN int, comprobante:OUT Comprobante)
End Empleado

Task type Cliente

arrClientes: array(1..C) of Cliente

/* Definición de bodys */

Task Body Cliente is
    monto:int
    comprobante:Comprobante
Begin
    monto = montoAPagar()
    //llega al banco y espera a que lo atiendan
    Select
        Empleado.RecibirPago(monto,comprobante)
    OR Delay 600
        null
    End Select
End Cliente

Task Body Empleado is
    monto:int
    comprobante:Comprobante
Begin
    loop
        Accept RecibirPago(monto:IN int, comprobante:OUT Comprobante)
            comprobante = ProcesarPago(monto)
        end RecibirPago
    end loop
End Empleado

Begin
    null
End Ejercicio2

```




<!-- DUDA: REVISAR, ME COSTÓ. -->
# Ejercicio 3: sistema central y perifericos
Se dispone de un sistema compuesto por 1 central y 2 procesos periféricos, que se comunican continuamente.
Se requiere modelar su funcionamiento considerando las siguientes condiciones:
- La central siempre comienza su ejecución tomando una señal del proceso 1; 
  - luego toma aleatoriamente señales de cualquiera de los dos indefinidamente. 
  - Al recibir una señal de proceso 2, recibe señales del mismo proceso durante 3 minutos.
- Los procesos periféricos envían señales continuamente a la central. 
  - La señal del proceso 1 será considerada vieja (se deshecha) si en 2 minutos no fue recibida.
  - Si la señal del proceso 2 no puede ser recibida inmediatamente, entonces espera 1 minuto y vuelve a mandarla (no se deshecha).

<!-- QUE HAGO CON LA SEÑAL?? -->
```java
Procedure Ejercicio3

Task Central is 
    entry ReciboSeñal_peri_1(señal:IN Señal)
    entry ReciboSeñal_peri_2(señal:IN Señal)
    entry FinContador()
End Central

Task Contador is
    entry IniciarContador()
end Contador

Task Periferico1
Task Periferico2 

Task body Central is
Begin
    Accept ReciboSeñal_peri_1(señal:IN Señal) do
        s = señal
    End Accept
    procesarSeñal(s)
    loop 
        Select 
            Accept ReciboSeñal_peri_1(señal:IN Señal) do procesarSeñal(señal) End ReciboSeñal_peri_1
        OR
            Accept ReciboSeñal_peri_2(señal:IN Señal) do
                s = señal
            End ReciboSeñal_peri_2
            contador.iniciarContador()
            procesarSeñal(señal)
            
            pasaron3Minutos = false
            while (not pasaron3Minutos) do
                Select
                    Accept FinContador() do
                        pasaron3Minutos = true
                    End FinContatod
                OR
                    when (FinContador´count == 0) Acept ReciboSeñal_peri_2(señal:IN Señal) do
                        s = señal
                    End ReciboSeñal_peri_2
                    procesarSeñal(s)
            end loop

        End Select
    end loop
    
End Central

Task body Periferico1 is
señal:Señal
Begin
    /* La señal del proceso 1 será considerada vieja (se deshecha) si en 2 minutos no fue recibida. */
    loop
        señal = generoSeñal() // por cada loop se genera una nueva señal
        Select
            Central.ReciboSeñal_peri_1(señal)
        OR delay (2 minutos)
    end loop
End Periferico1

Task body Periferico2 is
señal:Señal
Begin
    /* Si la señal del proceso 2 no puede ser recibida inmediatamente, entonces espera 1 minuto y vuelve a mandarla (no se deshecha). */
    señal = generoSeñal() 
    loop
        Select
            Central.ReciboSeñal_peri_2(señal)
            señal = generoSeñal() //se genera una nueva señal sólo si se acepto la anterior
        Else
            delay(1 minuto)
    end loop
End Periferico2


Task body Contador is
Begin
    loop
        Accept IniciarContador();
        delay(180);
        Central.FinContador();
    end loop;
End Contador;


Begin
null
End Ejercicio3



/* segunda version, del profe */

....
loop
        Select 
            when not solo2  Accept ReciboSeñal_peri_1(señal:IN Señal) do procesarSeñal(señal) End ReciboSeñal_peri_1
        OR
            when FinContador`count ==0 Accept ReciboSeñal_peri_2(señal:IN Señal) do
                s = señal
            End ReciboSeñal_peri_2
            if(not solo2)
                contador.iniciarContador()
                solo2 = true

            procesarSeñal(señal)
        OR
            Accept FinContador() 
                solo2 = false
        End Select















```


<!-- Duda: Corregir version final -->
# Ejercicio 4: médico y enfermeras
En una clínica existe un médico de guardia que recibe continuamente peticiones de atención de las E enfermeras que trabajan en su piso y de las P personas que llegan a la clínica ser atendidos.

Cuando una persona necesita que la atiendan espera a lo sumo 5 minutos a que el médico lo haga, si pasado ese tiempo no lo hace, espera 10 minutos y vuelve a requerir la atención del médico. Si no es atendida tres veces, se enoja y se retira de la clínica.

Cuando una enfermera requiere la atención del médico, si este no lo atiende inmediatamente le hace una nota y se la deja en el consultorio para que esta resuelva su pedido en el momento que pueda (el pedido puede ser que el médico le firme algún papel). Cuando la petición ha sido recibida por el médico o la nota ha sido dejada en el escritorio, continúa trabajando y haciendo más peticiones.

El médico atiende los pedidos dándole prioridad a los enfermos que llegan para ser atendidos. Cuando atiende un pedido, recibe la solicitud y la procesa durante un cierto tiempo. Cuando está libre aprovecha a procesar las notas dejadas por las enfermeras.




```java
Procedure Ejercicio4

Task Medico is 
    entry AtenderEnfermera(pedido:IN string)
    entry AtenderPaciente(pedido:IN string)

End Medico

Task Consultorio is
    entry RecibirNota(nota:IN string)
    entry SiguienteNota(nota:OUT string)
End Consultorio


Task type Enfermera

arrEnfermeras: array(1..E) of Enfermera
arrPacientes: array(1..P) of Paciente


Task Consultorio body is
    notas:Cola
    Begin
    loop
        Select 
            Accept RecibirNota(nota:IN string) do
                notas.push(nota)
            End RecibirNota
        Or
            when notas.notEmpty()
            Accept SiguienteNota(nota:OUT string) do
                nota = notas.pop()
            End Accept
    end loop
End Consultorio


Task Secretaria body is
    nota:string
    Begin
    loop
        consultorio.SiguienteNota(nota)
        medico.SiguienteNota(nota)
    end loop
End Secretaria



Task body Medico is
    aux:string
    Begin
    loop
        Select
            Accept AtenderPaciente(pedido:IN string) do
                aux = pedido 
            end Accept
        Or 
            when (AtenderPaciente`count == 0) 
            Accept AtenderEnfermera(pedido:IN string) do
                aux = pedido
            end Accept
        Or 
            when (AtenderPaciente`count == 0 and AtenderEnfermera`count == 0)
            Accept SiguienteNota(nota) do 
                aux = nota
            end Accept
        End Select
        procesar(aux)
    end loop
End Medico

/* TODO: BODY PACIENTE */


Begin

End Ejercicio4
```