--2. Se quiere modelar el funcionamiento de un banco, al cual llegan clientes que deben realizar un pago y retirar un comprobante. Existe un único empleado en el banco, el cual atiende de acuerdo con el orden de llegada. Los clientes llegan y si esperan más de 10 minutos se retiran sin realizar el pago.

Procedure Banco is
	Task Type cliente;
	-- Preguntar cuando se usa Type y cuando no
	
	Task Empleado is
		Entry Pago (plata: IN double, comprobante: OUT string);
	end Empleado
	
	arrClientes: array (1..N) of Cliente;
	
	Task Body Cliente is
		comprobante: string;
		plata: double;
	begin
		SELECT	
			Empleado.Pago(plata,comprobante);
		OR DELAY 600.0 
			NULL;
		END SELECT;
	end Cliente;
	
	Task Body Empleado is
	begin
		LOOP
			ACCEPT Pago (plata: IN double, comprobante: OUT string) do
				comprobante:= realizarPago(plata);
			END Pago;
		END LOOP
	end Empleado;
	
begin
	null;
end Banco;
