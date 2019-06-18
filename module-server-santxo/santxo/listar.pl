#!/usr/bin/perl 
open (PASSW,"/etc/passwd")|| die "No puedo abrir el archivo: /etc/passwd";
#Añadimos cada línea de éste en la matriz.
@registros=<PASSW>;
@registros= sort @registros;
@registros= grep {($nombre,$pass,$uid,$resto) =split(':',$_); $uid >= 500; } @registros;
foreach $linea (@registros)
	{
# Y esta linea la descomponemos en un vector
		@usuario=split(/:/,$linea);
     	($nombre,$sector,$tel,$otro)=split(/,/,@usuario[4]);
     	print ("$usuario[0],$nombre,$sector,$tel\n");
     	};
# Cerramos el fichero abierto
close (PASSW); 