Una empresa de limpieza se encarga de recolectar residuos en una ciudad por medio de 3 camiones. 
Hay P personas que hacen continuos reclamos hasta que uno de los camiones pase por su casa. Cada persona hace un reclamo, espera a lo sumo 15 minutos a que llegue un camión y si no vuelve a hacer el reclamo y a esperar a lo sumo 15 minutos a que llegue un camión y así sucesivamente hasta que el camión llegue y recolecte los residuos; en ese momento deja de hacer reclamos y se va. Cuando un camión está libre la empresa lo envía a la casa de la persona que más reclamos ha hecho sin ser atendido. 
Nota: maximizar la concurrencia.

Procedure EmpresaDeLimpieza is

Task AsignadorID is
	Entry getID(id: OUT integer);
end AsignadorID;

Task Administrador is
	Entry Reclamo(idPersona: IN integer);
	Entry Siguiente(idPersona: OUT integer);
end Administrador;

Task type Persona is -- el type va solo cuando tenes un arreglo de taks?
	Entry RecolectarResiduos();
end Persona;

Task type Camión;

arrPersonas: array (1 .. P) of Persona;
arrCamiones: array (1 .. 3) of Camión;

Task body AsignadorID is
-- Está bien encarado de esta forma o lo agrego como un campo mas del SELECT del admin?: Perfecto.
	FOR i IN 1 .. P LOOP
		ACCEPT getID (id: OUT integer) do
			id = i;
		end getID;
	end LOOP;
end AsignadorID;


Task body Administrador is
-- Se puede declarar el array así o hace falta definirlo antes con los otros arrays: Sí.
reclamos: array (1 ..P) of integer;
begin
	inicializar(reclamos);
	LOOP	
		SELECT
		 	when (Siguiente'count = 0) -> ACCEPT Reclamo (idPersona: IN integer) do
				if(reclamos[idPersona] <> -1)
					reclamos[idPersona]++;
			end Reclamo;
		OR 
			ACCEPT Siguiente(idPersona: OUT integer) do
					siguiente = IdMaxReclamos(reclamos);
					reclamos[siguiente] = -1;
					idPersona = siguiente;
			end Siguiente;
		end SELECT;
		
	end LOOP;
end;

Task body Camión is
begin
	LOOP
		Administrador.Siguiente(idPersona);
		arrPersona(idPersona).RecolectarResiduos();	
	end LOOP;
end;

Task body Persona is
id: integer;
llegóCamión: boolean;
begin
	AsignadorID.getID(id);
	llegóCamión = FALSE;
	WHILE (not llegóCamión) LOOP
		Administrador.Reclamo(id);
		SELECT 
			ACCEPT RecolectarResiduos() do
				llegóCamión = TRUE;
				-- Camión recolecta residuos
			end RecolectarResiduos;
		OR DELAY (15 minutos)
			null;
		end SELECT;
	end LOOP;
end Persona;



begin
	-- El PP puede tener entrys?: Nope.
	--FOR i IN 1 .. P LOOP
	--	ACCEPT getID (id: OUT integer) do
	--		id = i;
	--	end getID;
	--end LOOP;
	null;
end EmpresaDeLimpieza;

