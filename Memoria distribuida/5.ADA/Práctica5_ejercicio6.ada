En una playa hay 5 equipos de 4 personas cada uno (en total son 20 personas donde cada una conoce previamente a que equipo pertenece). Cuando las personas van llegando esperan con los de su equipo hasta que el mismo esté completo (hayan llegado los 4 integrantes), a partir de ese momento el equipo comienza a jugar. El juego consiste en que cada integrante del grupo junta 15 monedas de a una en una playa (las monedas pueden ser de 1, 2 o 5 pesos) y se suman los montos de las 60 monedas conseguidas en el grupo. Al finalizar cada persona debe conocer el grupo que más dinero junto. 
Nota: maximizar la concurrencia. Suponga que para simular la búsqueda de una moneda por parte de una persona existe una función Moneda() que retorna el valor de la moneda encontrada.

Procedure Playa is

Task Type Persona is
	Entry AsignarID(idJugador: IN integer)
	Entry EquipoCompleto();
	Entry EquipoGanador(ganador: IN integer);
end Persona;

Task Type Equipo is
	Entry AsignarID(idEquipo: IN integer);
	Entry LlegaJugador(id: IN integer);
	Entry EnviarMonto(monto: IN integer);
	Entry EquipoGanador(equipoGanador: IN integer);
end Equipo;

Task Coordinador is
	Entry EnviarMonto(idEquipo: IN integer; montoTotal: IN integer)
end Coordinador;

arrPersonas = array (1 .. 20) of Persona;
arrEquipos = array (1 .. 4) of Equipo;

--PERSONA--------------------------------------------------------------------
Task body Persona is
	id, nroEquipo, i, monto: integer;
begin
	nroEquipo = miNroDeEquipo();
	ACCEPT AsignarID(idJugador: IN integer) do
		id = idJugador;
	end AsignarID;
	
	Equipo(nroEquipo).LlegaJugador(id);
	ACCEPT EquipoCompleto();
	
	-- Comienza juego	
	monto = 0;
	FOR i in 1 .. 15 LOOP
		-- junta moneda
		monto = monto + Moneda();
	end LOOP;

	Equipo(nroEquipo).EnviarMonto(monto);
	ACCEPT EquipoGanador(ganador: IN integer);
end Persona;


--EQUIPO--------------------------------------------------------------------
Task body Equipo is
	nroEquipo, id, montoTotal, ganador: integer;
	jugadores: array (1 .. 4) of integer; --Queue? push: Enqueue y pop: Dequeue (viejo)
begin
	ACCEPT AsignarID(idEquipo: IN integer) do
		nroEquipo = idEquipo;
	end AsignarID;

	-- Espera que lleguen los 4 jugadores
	FOR i in 1 .. 4 LOOP
		ACCEPT LlegaJugador(id: IN integer) do
			jugadores(i) = id;
		end LlegaJugador;
	end LOOP;

	-- Les avisa a los jugadores que pueden comenzar
	FOR i in 1 .. 4 LOOP
		Jugador(jugadores(i)).EquipoCompleto();
	end LOOP;

	-- Recibe los montos de los jugadores
	montoTotal = 0;
	FOR i in 1 .. 4 LOOP
		ACCEPT EnviarMonto(monto: IN integer) do
			montoTotal = montoTotal + monto;
		end EnviarMonto;
	end LOOP;

	-- Le envía al coordinador para que calcule el mejor
	Coordinador.EnviarMonto(nroEquipo,montoTotal);
	
	-- Le informa a los jugadores de su equipo el mejor
	ACCEPT EquipoGanador(equipoGanador: IN integer) do
		ganador = equipoGanador;	
	end EquipoGanador; 
	FOR i in 1 ..4 LOOP
		Jugador(jugadores(i)).EquipoGanador(ganador)
	end LOOP
end Equipo;


--COORDINADOR--------------------------------------------------------------------
Task body Coordinador is
	i, max, maxEquipo: integer;
begin
	-- Asigna id a los equipos
	FOR i: 1 .. 5 LOOP
		Equipo(i).AsignarID(i);
	end LOOP;
	
	-- Asigna id a los jugadores
	FOR i: 1 .. 20 LOOP
		Jugador(i).AsignarID(i);
	end LOOP;

	-- Calcula el equipo con mayor monto
	max = -1;
	FOR i: 1 .. 5 LOOP
		ACCEPT EnviarMonto(idEquipo: IN integer; montoTotal: IN integer) do
			IF (montoTotal > max) THEN
				max = montoTotal;
				maxEquipo = idEquipo;
			end IF;
		end EnviarMonto;
	end LOOP;
	
	-- Le informa a los equipos
	FOR i: 1 .. 5 LOOP
		Equipo(i).EquipoGanador(maxEquipo);
	end LOOP;
end Coordinador;

begin
	null;
end Playa;







































--PERSONA--------------------------------------------------------------------
Task body Persona is
	id, nroEquipo, i, monto: integer;
begin
	nroEquipo = miNroDeEquipo();
	Equipo(nroEquipo).LlegaJugador();
	Equipo(nroEquipo).EquipoCompleto();
	
	-- Comienza juego	
	monto = 0;
	FOR i in 1 .. 15 LOOP
		-- junta moneda
		monto = monto + Moneda();
	end LOOP;

	Equipo(nroEquipo).EnviarMonto(monto);
	Equipo(nroEquipo).EquipoGanador(ganador);
end Persona;


--EQUIPO--------------------------------------------------------------------
Task body Equipo is
	nroEquipo, id, montoTotal, ganador: integer;
	jugadores: array (1 .. 4) of integer; --Queue? push: Enqueue y pop: Dequeue (viejo)
begin
	
	--necesito id para identificar el equipo ganador
	
	-- Espera que lleguen los 4 jugadores
	FOR i in 1 .. 4 LOOP
		ACCEPT LlegaJugador() do
		end LlegaJugador;
	end LOOP;

	-- Les avisa a los jugadores que pueden comenzar
	FOR i in 1 .. 4 LOOP
		accept EquipoCompleto();
	end LOOP;

	-- Recibe los montos de los jugadores
	montoTotal = 0;
	FOR i in 1 .. 4 LOOP
		ACCEPT EnviarMonto(monto: IN integer) do
			montoTotal = montoTotal + monto;
		end EnviarMonto;
	end LOOP;

	-- Le envía al coordinador para que calcule el mejor
	Coordinador.EnviarMonto(nroEquipo,montoTotal);
	
	-- Le informa a los jugadores de su equipo el mejor
	
	Coordinador.EquipoGanador(ganador) do
		 
	FOR i in 1 ..4 LOOP
		accept EquipoGanador(gan OUT int)
			gan = ganador
		end accept
	end LOOP
end Equipo;







