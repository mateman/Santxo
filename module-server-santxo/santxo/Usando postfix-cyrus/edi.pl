#!/usr/bin/perl 
open (PASSW,"/etc/passwd")|| die "No puedo abrir el archivo: /etc/passwd";
#Añadimos cada línea de éste en la matriz.
@registros=<PASSW>;
@registros= grep {($nombre,$resto) =split(':',$_); $nombre eq $ARGV[0]; } @registros;
# Cerramos el fichero abierto
close (PASSW);
@cuenta = split (/:/,$registros[0]);
($nombre,$sector,$tel)=split (/\,/,$cuenta[4]);
print ("$nombre,$sector,$tel");						