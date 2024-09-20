### ADA (2021)
Resolver con ADA el siguiente problema. Simular la venta de entradas a un evento musical por medio de un portal web. Hay N clientes que intentan comprar una entrada para el evento; los clientes pueden ser regulares o especiales (clientes que están asociados al sponsor del evento).
Cada cliente especial hace un pedido al portal y espera hasta ser atendido; cada cliente regular hace un pedido y si no es atendido antes de los 5 minutos, vuelve a hacer el pedido siguiendo el mismo patrón (espera a lo sumo 5 minutos y si no lo vuelve a intentar) hasta ser atendido. 
Después de ser atendido, si consiguió comprar la entrada, debe imprimir el comprobante de la compra.
El portal tiene E entradas para vender y atiende los pedidos de acuerdo al orden de llegada pero dando prioridad a los Clientes Especiales. Cuando atiende un pedido, si aún quedan entradas disponibles le vende una al cliente que hizo el pedido y le entrega el comprobante.
Nota: no debe modelarse la parte de la impresión del comprobante, sólo llamar a una función Imprimir (comprobante) en el cliente que simulará esa parte; la cantidad E de entradas es mucho menor que la cantidad de clientes (T << C); todas las tareas deben terminar.


Procedure ParcialADA is

Task type Cliente;
Task Portal is
	Entry PedidoRegular(idCliente: IN integer, entrada: OUT integer, comprobante: OUT string);
	Entry PedidoEspecial(idCliente: IN integer, entrada: OUT integer, comprobante: OUT string);
end Portal;

arrClientes: array (1 .. N) of Cliente;

Task body Cliente is
begin
	string miPrioridad = getPrioridad();
	integer entrada;
	string comprobante;
	boolean atendido = false;
	
	IF (miPrioridad = "Especial") THEN
      		Portal.PedidoEspecial(id, entrada, comprobante)
   	ELSE
			WHILE (not atendido) LOOP
		   		SELECT
		       		Portal.PedidoRegular(id, entrada, comprobante)
					atendido = true
		   		OR DELAY (5 minutos)
		      		Null;
		   		end SELECT;
       		end LOOP;
   	End IF;
	IF (entrada <> -1) THEN
          Imprimir(comprobante);
	End IF	
end Cliente;


Task body Portal is
begin
 	LOOP
		SELECT 
			ACCEPT PedidoEspecial (idCliente: IN integer, entrada: OUT integer, comprobante: OUT string) do
				IF (not empty (entradas)) THEN
				   	pop (entradas,entrada)
				   	comprobante = comprobanteDeEntrada();
        	 	ELSE
               		entrada = -1;
               		comprobante = "";
				end IF;		
			end PedidoEspecial;
		OR
			WHEN (PedidoEspecial'count = 0) -> ACCEPT PedidoRegular(idCliente: IN integer, entrada: OUT integer, comprobante: OUT string) do
            	IF (not empty (entradas)) THEN
					pop (entradas,entrada)
					comprobante = comprobanteDeEntrada();
              	ELSE
                    entrada = -1;
                    comprobante = "";
			    end IF;		
			end PedidoRegular;

		end SELECT;		
 	end LOOP
end Portal;


begin
	null;
end ParcialADA;


### ADA 2. recuperatorio
Resolver con ADA el siguiente problema. Una empresa de venta de calzado cuenta con S sedes. En la oficina central de la empresa se utiliza un sistema que permite controlar el stock de los diferentes modelos, ya que cada sede tiene una base de datos propia. El sistema de control de stock funciona de la siguiente manera: dado un modelo determinado, lo envía a las sedes para que cada una le devuelva la cantidad disponible en ellas; al final del procesamiento, el sistema informa el total de calzados disponibles de dicho modelo. Una vez que se completó el procesamiento de un modelo, se procede a realizar lo mismo con el siguiente modelo.
Nota: suponga que existe una función DevolverStock(modelo,cantidad) que utiliza cada sede donde recibe como parámetro de entrada el modelo de calzado y retorna como parámetro de salida la cantidad de pares disponibles. Maximizar la concurrencia y no generar demora innecesaria

Procedure Recuperatorio is
Task OficinaCentral 
Task type Sede 

arrSedes: array (1 .. S) of Sede;

task body OficinaCentral is
	siguienteModelo: string;
	cantidadTotal, i: integer;
begin
	siguienteModelo = getModelo();
	cantidadTotal = 0;
	LOOP
		FOR i IN 1 .. S LOOP
			ACCEPT ReporteModelo(modelo: OUT string) do
				modelo = siguienteModelo;
			end ReporteModelo;
		end LOOP
		FOR i IN 1 .. S LOOP
			ACCEPT ReporteCantidad(cantidad: IN integer) do
				cantidadTotal = cantidadTotal + cantidad;
			end ReporteModelo;
		end LOOP
		Informar("Cantidad de calzados disponibles para ",siguienteModelo," es ", cantidadTotal);
		siguienteModelo = getModelo();
	end LOOP;
end oficinaCentral;

task body Sede is
	modelo: string;
	cantidad: integer;
begin
	LOOP
		OficinaCentral.ReporteModelo(modelo);
		DevolverStock(modelo,cantidad);
		OficinaCentral.ReporteCantidad(cantidad);
		
	end LOOP;
end Sede;


begin
	null;
end Recuperatorio;



### ADA 2022
Resolver con ADA el siguiente problema. Se quiere modelar el funcionamiento de un banco, al cual llegan clientes que deben realizar un pago y llevarse su comprobante. Los clientes se dividen entre los regulares y los premium, habiendo R clientes regulares y P clientes premium. Existe un único empleado en el banco, el cual atiende de acuerdo al orden de llegada, pero dando prioridad a los premium sobre los regulares. Si a los 30 minutos de llegar un cliente regular no fue atendido, entonces se retira sin realizar el pago. Los clientes premium siempre esperan hasta ser atendidos.

Procedure Parcial2022 is

Task type ClienteRegular;
Task type ClientePremium;
Task Empleado is
	Entry PagoPremium(plata: IN integer; comprobante: OUT string);
	Entry PagoRegular(plata: IN integer; comprobante: OUT string);
end Empleado;

arrClientesRegulares: array (1 .. R) of ClienteRegular;
arrClientesPremium: array (1 .. P) of ClientePremium;


Task body ClienteRegular is
	plata: integer;
	comprobante: string;
begin
	plata = plataParaPago();
	SELECT 
		Empleado.PagoRegular(plata,comprobante);
	OR DELAY (30 minutos)
		null;
	end SELECT;
end ClienteRegular;


Task body ClientePremium is
	plata: integer;
	comprobante: string;
begin
	plata = plataParaPago();
	Empleado.PagoPremium(plata,comprobante);
end ClientePremium;


Task body Empleado is
begin
	LOOP
		SELECT 
			ACCEPT PagoPremium(plata: IN integer; comprobante: OUT string) do
				comprobante = ProcesarPago(plata);
			end PagoPremium;
		OR
			WHEN (PagoPremium'count = 0) -> ACCEPT PagoRegular(plata: IN integer; comprobante: OUT string) do
				comprobante = ProcesarPago(plata);
			end PagoRegular;
	end LOOP;
end Empleado;


begin
	null;
end;




(3.SegundoRecuperatorio)
Resolver con ADA el siguiente problema. Se debe controlar el acceso a una base de datos. Existen L procesos Lectores y E procesos Escritores que trabajan indefinidamente de la siguiente manera:
• Escritor: intenta acceder para escribir, si no lo logra inmediatamente, espera 1 minuto y vuelve a intentarlo de la misma manera.
• Lector: intenta acceder para leer, si no lo logro en 2 minutos, espera 5 minutos y vuelve a intentarlo de la misma manera.
Un proceso Escritor podrá acceder si no hay ningún otro proceso usando la base de datos; al acceder escribe y sale de la BD. Un proceso Lector podrá acceder si no hay procesos Escritores usando la base de datos; al acceder lee y sale de la BD. Siempre se le debe dar prioridad al pedido de acceso para escribir sobre el pedido de acceso para leer.

