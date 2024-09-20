4. En una clínica existe un médico de guardia que recibe continuamente peticiones de atención de las E enfermeras que trabajan en su piso y de las P personas que llegan a la clínica ser atendidos.
- Cuando una persona necesita que la atiendan espera a lo sumo 5 minutos a que el médico lo haga, si pasado ese tiempo no lo hace, espera 10 minutos y vuelve a requerir la atención del médico. Si no es atendida tres veces, se enoja y se retira de la clínica.
- Cuando una enfermera requiere la atención del médico, si este no lo atiende inmediatamente le hace una nota y se la deja en el consultorio para que este resuelva su pedido en el momento que pueda (el pedido puede ser que el médico le firme algún papel). Cuando la petición ha sido recibida por el médico o la nota ha sido dejada en el escritorio, continúa trabajando y haciendo más peticiones.
- El médico atiende los pedidos dándole prioridad a los enfermos que llegan para ser atendidos. Cuando atiende un pedido, recibe la solicitud y la procesa durante un cierto tiempo. Cuando está libre aprovecha a procesar las notas dejadas por las enfermeras.

Procedure Clinica is

Task Type Persona
Task Type Enfermera

Task Médico is
	Entry AtenciónP;
	Entry AtenciónE;
	Entry Notas;
end Médico;

arrPersonas: array (1 .. P) of Persona;
arrEnfermeras: = array of (1 .. E) Enfermera;

Task body Persona is
begin
	atendido = false;
	intentos = 0;
	while intentos < 3 && not atendido LOOP
		SELECT
			Médico.AtenciónP(); 
			atendido= true
		OR  DELAY (5 minutos)
			intentos ++
			delay(10 minutos);
		end SELECT;
	end LOOP		
---------------viejo-------------------------------------------------------------
--	SELECT
--		Médico.AtenciónP(); --Solicita atención del médico #1
--	OR DELAY 300 --Espera 5 minutos
--		DELAY 600 --Espera 10 minutos
--		SELECT
--			Médico.AtenciónP(); --Y vuelve a solicitar la atención del médico #2
--		OR DELAY 300
--			DELAY 600; 
--			SELECT
--				Médico.AtenciónP(); -- #3
--			OR DELAY 300
--				-- Se va enojada de la clínica
--			end SELECT;
--		end SELECT;
--	end SELECT;
-----------------------------------------------------------------------------------
end Persona;

Task body Enfermera is
begin
	LOOP
		SELECT
			Médico.AtenciónE();
		ELSE
			nota = EscribirNota();
			Escritorio.Notas(nota);
		end SELECT;
		-- Continúa trabajando
	end LOOP;
end Enfermera;



Escritorio is
notas: cola of Nota
loop
	select 
		when SigNota'count = 0
		accept Notas(n IN: nota)t
			notas.push(n)
		end
	or when not notas.empty
		accept SigNota(n  OUT: Nota)
			n = notas.pop()
		end;
end loop;


-- Falta proceso secretaria que le deje las notas del escritorio al medico

Task body Médico is
begin
	LOOP
		SELECT
			ACCEPT AtenciónP do
				--Atender enfermo
			end AtenciónP;
		OR 
			WHEN (AtenciónP'count == 0) => 
				ACCEPT AteciónE;
		OR
			WHEN (AtenciónP'count == 0 and AtenciónE'count == 0)
			ACCEPT Notas(nota) do
				--Firmar nota
			end Notas;
		end SELECT
	end LOOP;
end Médico;

begin
end Clinica; 
