5. En un sistema para acreditar carreras universitarias, hay UN Servidor que atiende pedidos de U Usuarios de a uno a la vez y de acuerdo con el orden en que se hacen los pedidos.
Cada usuario trabaja en el documento a presentar, y luego lo envía al servidor; espera la respuesta de este que le indica si está todo bien o hay algún error. Mientras haya algún error, vuelve a trabajar con el documento y a enviarlo al servidor. Cuando el servidor le responde que está todo bien, el usuario se retira. Cuando un usuario envía un pedido espera a lo sumo 2 minutos a que sea recibido por el servidor, pasado ese tiempo espera un minuto y vuelve a intentarlo (usando el mismo documento).

Procedure Sistema is

	Task Servidor is
		Entry Documentos(documento: in string; respuesta: out string);
	end Servidor;

	Task Type Usuario;

	arrUsuarios: array (1 .. U) of Usuario;

	Task body Servidor
	begin
		LOOP
			ACCEPT Documentos(documento, respuesta) do
				tieneErrores = AnalizarDocumento(documento);
				if (tieneErrores) then respuesta = "error";
				else respuesta = "todo bien";
			end Documentos;
		end LOOP
	end Servidor;

	Task body Usuario is
		error: boolean;
		documento: string;
	begin
		error = true;
		documento = "";
		WHILE (error) LOOP
			SELECT 
				Servidor.Documentos(documento,respuesta);
				IF (respuesta <> "error") THEN error = false;
				else documento = TrabajaEnDocumento(documento);
			
			OR DELAY 120
				DELAY 60
				--Servidor.Documentos(documento,respuesta); --Cómo hacerlo iterativo
			end SELECT;
		end LOOP;
	end Usuario;

begin
end Sistema;
