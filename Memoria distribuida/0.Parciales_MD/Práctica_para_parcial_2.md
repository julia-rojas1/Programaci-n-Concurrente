# PMA
## Ejercicio 2

    ```java
    chan Fila(int, boolean);
    chan HayAlgo();
    chan[] Clientes[N](int);
    chan[] CajasE[3](int);
    chan[] CajasR[3](int);
    chan[] Comprobantes[N](String);
    chan Listo(int, boolean);
    chan[] TenesAlgo[3]();

    Procedure Cliente [id: 0..N-1] {
        boolean prioridad = soyEspecial();
        int caja_id;
        String mi_comprobante;
        send Fila(id, prioridad);
        send HayAlgo();
        receive Clientes[id](caja_id);
        if prioridad send CajasE[caja_id](id);
        else send CajasR[caja_id](id);
        send TenesAlgo[caja_id]();
        receive Comprobantes[id](mi_comprobante);
    }

    Procedure Coordinador {
        int[] filasE[3], filasR[3] = 0;
        int caja_id, cliente_id;
        boolean prioridad;
        while (true) {
            receive HayAlgo();
            if (not empty(Fila)) {
                receive Fila(cliente_id, prioridad);
                if prioridad {
                    int fila_min = posMinimo(filasE);
                    filasE[fila_min]++;
                } else {
                    int fila_min = posMinimo(filasR);
                    filasR[fila_min]++;
                }
                send Clientes[N](fila_min);
            }
            [] (not empty(Listo)) {
                receive Listo(caja_id, prioridad);
                if prioridad filasE[caja_id]++;
                else filasR[caja_id]++;
            }
        }
    }

    Procedure Caja [id: 0..2] {
        boolean prioridad;
        int cliente_id;
        while (true) {
            receive TenesAlgo[id]();
            if (not empty(CajasE[id])) {
                receive CajasE[id](cliente_id);
                prioridad = true;
            }
            [] ((empty(CajasE[id])) and (not empty(CajasR[id]))) {
                receive CajasR[id](cliente_id);
                prioridad = false;
            }
            String comprobante = atender(cliente_id);
            send Comprobantes[cliente_id](comprobante);
            send Listo(id, prioridad);
        }
    }
    ```

## Ejercicio 5

    ```java
    chan FilaE(int);
    chan FilaR(int);
    chan HayAlgo();
    chan[] PersonasE[E](int);
    chan[] PersonasR[R](int);
    chan Listo(int);

    Process PersonaE [id:0..E] {
        int maquina_id;
        send FilaE(id);
        send HayAlgo();
        receive PersonasE[id](maquina_id);
        // Usa la máquina {maquina_id}
        delay(10, min);
        send Listo(maquina_id);
        send HayAlgo();
    }
    chan Listo(int);

    Process PersonaR [id:0..R] {
        int maquina_id;
        send FilaR(id);
        send HayAlgo();
        receive PersonasR[id](maquina_id);
        // Usa la máquina {maquina_id}
        delay(10, min);
        send Listo(maquina_id);
        send HayAlgo();
    }

    Process Coordinador {
        int persona_id, maquina_id;
        Pila libres;
        for (int i = 0; i < 3; i++) push(libres, i);
        while (true) {
            receive HayAlgo();
            //receive SolicitudMaquina(id_M)
            if (not empty(FilaE) and not empty(libres)) {
                receive FilaE(persona_id);
                send PersonasE[persona_id](pop(libres));
            }
            [] (empty(FilaE) and not empty(FilaR) and not empty(libres)) {
                receive FilaR(persona_id);
                send PersonasR[persona_id](pop(libres));
            }
            [] (not empty(Listo) or empty(libre)) {
                receive Listo(maquina_id);
                push(libres, maquina_id);
            }
        }
    }
    ```

# PMS
## Ejercicio 2

    ```java
    Procedure Estudiante [id: 0..E-1] {
        Microondas!llegue(id);
        Microondas!ok();
        usarMicroondas();
        Microondas!listo();
    }

    Procedure Microondas {
        Cola pendientes;
        int estudiante_id;
        boolean libre = true;
        do Estudiante[*]?llegue(estudiante_id) -->
            if (libre) {
                Estudiante[estudiante_id]?ok();
                libre = false;
            } else push(pendientes, estudiante_id);
        [] Estudiante[*]?listo() -->
            if (empty(pendientes)) libre = true;
            else Estudiante[pop(pendientes)]?ok();
        od;
    }
    ```

# ADA
## Ejercicio 3

    ```java
    Procedure practicaE3 is

    Task type Lector;
    lectores = array (1..L) of Lector;

    Task type Escritor;
    escritores = array (1..E) of Escritor;

    Task Administrador is
        entry leer();
        entry escribir();
        entry ListoL();
        entry ListoE();
    End Administrador;

    Task body Lector is
        info: String;
    Begin
        loop
            SELECT
                Administrador.leer();
                leerDeBD(info);
                Administrador.listoL();
            OR DELAY 120.0
                delay(5, min);
            END SELECT;
        end loop;
    End Lector;

    Task body Escritor is
        info: String;
    Begin
        loop
            info = generarInfo();
            SELECT
                Administrador.escribir();
                escribirEnBD(info);
                Administrador.listoE();
            OR ELSE
                delay(1, min);
            END SELECT;
        end loop;
    End Escritor;

    Task body Administrador is
        cantL, cantE: int := 0;
    Begin
        loop
            SELECT
                when ((cantL = 0) and (cantE = 0)) =>
                    accept escribir();
                    cantE++;
            OR
                when ((cantE = 0) and (escribir''count = 0)) =>
                    accept leer();
                    cantL++;
            OR
                accept listoL();
                cantL--;
            OR
                accept listoE();
                cantE--;
            END SELECT;
        end loop;
    End Administrador;

    Begin
        null;
    End;
    ```

## Ejercicio 4

    ```java
    Procedure practicaE4 is
    
    Task type ClienteE;
    clientesE = array (1..E) of ClienteE;
    
    Task type ClienteR;
    clientesR = array (1..R) of ClienteR;

    Task Portal is
        entry SacarEntradaE(tengo_entrada: out boolean; comprobante out String);
        entry SacarEntradaR(tengo_entrada: out boolean; comprobante out String);
    End Portal;

    Task body ClienteE is
        tengo_entrada: boolean;
        comprobante: String;
    Begin
        Portal.SacarEntradaE(tengo_entrada, comprobante);
        if (tengo_entrada) then
            Imprimir(comprobante);
        end if;
    End ClienteE;

    Task body ClienteR is
        tengo_entrada, sigo: boolean;
        comprobante: String;
    Begin
        sigo := true;
        while sigo loop
            SELECT
                Portal.SacarEntradaR(tendo_entrada, comprobante);
                sigo := false;
            OR DELAY 300.0;
                null;
            END SELECT;
        end loop;
        if (tengo_entrada) then
            Imprimir(comprobante);
        end if;
    End ClienteR;

    Task body Portal is
        entradas: int;
    Begin
        entradas := T;
        for i in 1..(E+R) loop
            SELECT
                accept SacarEntradaE(tengo_entrada: out boolean; comprobante out String) do
                    if (entradas > 0) then
                        tengo_entrada := true;
                        comprobante := generarComprobante();
                        entradas := entradas - 1;
                    else
                        tengo_entrada := false;
                    end if;
                end SacarEntradaE;
            OR
                when (SacarEntradaE''count = 0) =>
                    accept SacarEntradaR(tengo_entrada: out boolean; comprobante out String) do
                        if (entradas > 0) then
                            tengo_entrada := true;
                            comprobante := generarComprobante();
                            entradas := entradas - 1;
                        else
                            tengo_entrada := false;
                        end if;
                    end SacarEntradaR;
            END SELECT;
        end loop;
    End Portal;

    Begin
        null;
    End practicaE4;
    ```

## Ejercicio 7 (Consignas.txt)

    ```java
    Procedure practicaE7 is

    Task type TrabajadorA;
    trabajadoresA = array (1..A) of TrabajadorA;
    
    Task type TrabajadorB;
    trabajadoresB = array (1..B) of TrabajadorB;

    Task type Tecnico;
    tecnicos = array (1..T) of Tecnico;

    Task AccesoImpresora is
        entry pedir();
        entry liberar();
    End AccesoImpresora;

    Task body TrabajadorA is
        resumen: String;
    Begin
        String resumen = trabajar();
        AccesoImpresora.pedir();
        Imprimir(resumen);
        AccesoImpresora.liberar();
    End TrabajadorA;

    Task body TrabajadorB is
        resumen: String;
    Begin
        resumen = trabajar();
        SELECT
            AccesoImpresora.pedir();
            Imprimir(resumen);
            AccesoImpresora.liberar();
        OR DELAY 120.0;
            null;
        END SELECT;
    End TrabajadorA;

    Task body Tecnico is
    Begin
        AccesoImpresora.pedir();
        if (hayError()) {
            // Lo resuelve
            delay(2, min);
        }
        AccesoImpresora.liberar();
    End Tecnico;

    Task body AccesoImpresora {
        loop
            accept pedir();
            accept liberar();
        end loop;
    }

    Begin
        null;
    End practicaE7;
    ```