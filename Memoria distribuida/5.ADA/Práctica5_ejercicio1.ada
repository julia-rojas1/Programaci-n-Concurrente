Se requiere modelar un puente de un único sentido que soporta hasta 5 unidades de peso. El peso de los vehículos depende del tipo: cada auto pesa 1 unidad, cada camioneta pesa 2 unidades y cada camión 3 unidades. Suponga que hay una cantidad innumerable de vehículos (A autos, B camionetas y C camiones). Analice el problema y defina qué tareas, recursos y sincronizaciones serán necesarios/convenientes para resolver el problema.

--a. Realice la solución suponiendo que todos los vehículos tienen la misma prioridad.
Procedure Puente is

    Task Type Auto;
    Task Type Camioneta;
    Task Type Camion;

    Task Type Pasaje is
        Entry EntradaA;
        Entry EntradaB;
        Entry EntradaC;
        Entry Salida(peso: IN double);
    end Pasaje;

    arrA: array (1..A) of Auto
    arrB: array (1..B) of Camioneta
    arrC: array (1..C) of Camion

    Task Body Pasaje is
    	pesoTotal:= 0, peso: Integer;
    Begin
	LOOP
		SELECT 
			WHEN(pesoTotal<=4)=> ACCEPT EntradaA IS
				pesoTotal:= pesoTotal + 1
			end EntradaA
		OR
			WHEN(pesoTotal<=3)=> ACCEPT EntradaB IS
				pesoTotal:= pesoTotal + 2
			end EntradaB
		OR
			WHEN(pesoTotal<=2)=> ACCEPT EntradaC IS
				pesoTotal:= pesoTotal + 3
			end EntradaC
		OR
			ACCEPT Salida(peso: IN Integer) do
			    pesoTotal = pesoTotal - peso
			end Salida
		End SELECT
	END LOOP;
    end Pasaje;

    Task Body Auto is
    begin
        Pasaje.EntradaA;
        -- Cruza puente
        Pasaje.Salida(1)
    end Auto;  
    
    Task Body Camioneta is
    begin
        Pasaje.EntradaB;
        -- Cruza puente
        Pasaje.Salida(2);
    end Camioneta; 
     
    Task Body Camion is
    begin
        Pasaje.EntradaC;
        -- Cruza puente
        Pasaje.Salida(3)
    end Camion;   
    
Begin
	null
End Puente

--b. Modifique la solución para que tengan mayor prioridad los camiones que el resto de los vehículos.
Procedure Puente is

    Task Type Auto;
    Task Type Camioneta;
    Task Type Camion;

    Task Type Pasaje is
        Entry EntradaA;
        Entry EntradaB;
        Entry EntradaC;
        Entry Salida(peso: IN double);
    end Pasaje;

    arrA: array (1..A) of Auto
    arrB: array (1..B) of Camioneta
    arrC: array (1..C) of Camion

    Task Body Pasaje is
    	pesoTotal:= 0: Integer;
    Begin
	LOOP
		SELECT 
			WHEN(pesoTotal<=4 AND EntradaC'count=0)=> ACCEPT EntradaA IS
				pesoTotal:= pesoTotal + 1
			end EntradaA
		OR
			WHEN(pesoTotal<=3 AND EntradaC'count=0)=> ACCEPT EntradaB IS
				pesoTotal:= pesoTotal + 2
			end EntradaB
		OR
			WHEN(pesoTotal<=2)=> ACCEPT EntradaC IS
				pesoTotal:= pesoTotal + 3
			end EntradaC
		OR
			ACCEPT Salida(peso: IN Integer) do
			    pesoTotal = pesoTotal - peso
			end Salida
		End SELECT
	END LOOP;
    end Pasaje;

    Task Body Auto is
    begin
        Pasaje.EntradaA;
        -- Cruza puente
        Pasaje.Salida(1)
    end Auto;  
    
    Task Body Camioneta is
    begin
        Pasaje.EntradaB;
        -- Cruza puente
        Pasaje.Salida(2);
    end Camioneta; 
     
    Task Body Camion is
    begin
        Pasaje.EntradaC;
        -- Cruza puente
        Pasaje.Salida(3)
    end Camion;   
    
Begin
	null
End Puente

