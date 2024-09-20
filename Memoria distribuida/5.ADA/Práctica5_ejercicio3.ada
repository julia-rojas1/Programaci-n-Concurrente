3. Se dispone de un sistema compuesto por 1 central y 2 procesos periféricos, que se comunican continuamente. Se requiere modelar su funcionamiento considerando las siguientes condiciones:
- La central siempre comienza su ejecución tomando una señal del proceso 1; luego toma aleatoriamente señales de cualquiera de los dos indefinidamente. Al recibir una señal de proceso 2, recibe señales del mismo proceso durante 3 minutos.
- Los procesos periféricos envían señales continuamente a la central. La señal del proceso 1 será considerada vieja (se deshecha) si en 2 minutos no fue recibida. Si la señal del proceso 2 no puede ser recibida inmediatamente, entonces espera 1 minuto y vuelve a mandarla (no se deshecha).

Procedure Sistema is

Task Central is
	Entry señal1; -- Paréntesis cuano no hay parámetros?
	Entry señal2;
	Entry FinContador;
end Central

Task Contador is
	Entry IniciarContador;
end Contador;

Task Type Periferico1;
Task Type Periferico2;

----------------------VIEJO----------------------------------------
--Task body Central is
--	ACCEPT señal1;
--	LOOP
--		SELECT 
--			ACCEPT señal1;
--		OR
--			ACCEPT señal2 do
--				SELECT
--					ACCEPT señal2;
--				OR DELAY 180;
--					null;
-- Espera por lo menos 180 segundos a que haya mensajes en señal2 para aceptarlas?
-- Si acepta 1 y no pasaron los 180 segundos, sigue esperando o sale del bloque select?
--				end SELECT;
--			end señal2;
--		end SELECT;
--	end LOOP;
--end Central;
-------------------------------------------------------------------

Task body Contador is
begin
    LOOP
        ACCEPT IniciarContador();
        DELAY(180);
        Central.FinContador();
    end LOOP;
end Contador;

Task body Central is
begin
	ACCEPT señal1;
	LOOP
		SELECT 
			ACCEPT señal1;
		OR
			ACCEPT señal2;

			Contador.IniciarContador;
			pasaron3Minutos = false

			WHILE (not pasaron3Minutos) LOOP
				SELECT
					ACCEPT FinContador do
						pasaron3Minutos = true;
					end FinContador;
				OR 
					WHEN (FinContador'count == 0) => 
						ACCEPT señal2;
				end SELECT;
			end LOOP;
		end SELECT;
	end LOOP;
end Central;

Task body Periferico1 is
begin
	LOOP
		s = generaSeñal()
		SELECT
			Central.señal1(s); 
		OR DELAY 120
			null;
		end SELECT;
	end LOOP;
end Periferico1;

Task body Periferico2 is
begin
	s = generaSeñal()
	LOOP
		SELECT
			Central.señal2(s); 
			s = generaSeñal()
		ELSE
			DELAY 60
		end SELECT;
	end LOOP;
end Periferico2;


begin
	null;
end Sistema;
