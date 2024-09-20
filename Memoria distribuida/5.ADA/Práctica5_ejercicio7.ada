Hay un sistema de reconocimiento de huellas dactilares de la policía que tiene 8 Servidores para realizar el reconocimiento, cada uno de ellos trabajando con una Base de Datos propia; a su vez hay un Especialista que utiliza indefinidamente. 
El sistema funciona de la siguiente manera: el Especialista toma una imagen de una huella (TEST) y se la envía a los servidores para que cada uno de ellos le devuelva el código y el valor de similitud de la huella que más se asemeja a TEST en su BD; al final del procesamiento, el especialista debe conocer el código de la huella con mayor valor de similitud entre las devueltas por los 8 servidores.
Cuando ha terminado de procesar una huella comienza nuevamente todo el ciclo. 
Nota: suponga que existe una función Buscar(test, código, valor) que utiliza cada Servidor donde recibe como parámetro de entrada la huella test, y devuelve como parámetros de salida el código y el valor de similitud de la huella más parecida a test en la BD correspondiente. Maximizar la concurrencia y no generar demora innecesaria

Procedure Sistema

Task type Servidor is
	Entry ImagenHuella(TEST: IN string);
end Servidor;

Task Especialista is
	Entry ResultadosTEST(codigo: IN integer; valorSimilitud: IN integer);
end Especialista;

arrServidores: array (1 .. 8) of Servidor;


Task body Servidor is
código, valor: integer;
begin
	LOOP
		ACCEPT ImagenHuella(TEST: IN string) DO
			Buscar(TEST, código, valor);  -- MAL!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		end ImagenHuella;

		Especialista.ResultadosTEST(código, valor);
	end LOOP;
end Servidor;


Task body Especilista is
TEST: string;
i, maxVS, codMax: integer;
begin
	LOOP
		-- Toma una imagen de una huella
		TEST = tomaImagenHuella();

		-- Se la envía a los servidores para que la procesen
		FOR i in 1 .. 8 LOOP
			Servidor(i).ImagenHuella(TEST);
		end LOOP;

		-- Recibe los resultados de los servidores y se queda con el código que mas similitud tenga
		FOR i in 1 .. 8 LOOP
			ACCEPT ResultadosTEST(codigo: IN integer; valorSimilitud: IN integer) do
				IF (valorSimilitud > maxVS) THEN
					maxVS = valorSimilitud;
					codMax = codigo;
				end IF;
			end ResultadosTEST;
		end LOOP;

	end LOOP;
end Especialista;

begin
end Sistema;






Task body Servidor is
código, valor: integer;
begin
	LOOP
		Especialista.ImagenHuella(TEST) 
		Buscar(TEST, código, valor);		
		Especialista.ResultadosTEST(código, valor);
		
		-- barrera
	end LOOP;
end Servidor;


Task body Especilista is
TEST: string;
i, maxVS, codMax: integer;
begin
	LOOP
		-- Toma una imagen de una huella
		TEST = tomaImagenHuella();

		-- Se la envía a los servidores para que la procesen
		FOR i in 1 .. 8 LOOP
			accept ImagenHuella(h OUT : string)
				h = TEST
			end accept
		end LOOP;

		-- Recibe los resultados de los servidores y se queda con el código que mas similitud tenga
		FOR i in 1 .. 8 LOOP
			ACCEPT ResultadosTEST(codigo: IN integer; valorSimilitud: IN integer) do
				IF (valorSimilitud > maxVS) THEN
					maxVS = valorSimilitud;
					codMax = codigo;
				end IF;
			end ResultadosTEST;
		end LOOP;

	end LOOP;
end Especialista;



	for 1..16
		select
			accept ImagenHuella
		or
			when ImagenHuella'count = 0
			accept ResultadoTEST
	
	-- esta solucion necesita barrera para evitar dar la misma huella dos veces al mismo servidor
	

begin
end Sistema;
