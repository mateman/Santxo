#!/usr/bin/perl
#
# Hecho por Pablo Adolfo Cuyeu (cuyeu@hotmail.com)
#

use comun;

# Comienza el programa principal
%hash_registros=&decodificar_config("/etc/santxo.cfg");
my $hostsession = $hash_registros{'session-dir'};
my $timesession = $hash_registros{'session-tiempo'};
my $host = $hash_registros{'home'};
$host =~ s/\n//g;
$timesession =~ s/\n//g;
$hostsession =~ s/\n//g;	
&delete_old($host,$hostsession,$timesession);
my $archivos = $host ."/common";
my $dominio = "mail@" . $hash_registros{'dominio'};
open (COLORS,$host."/config/colors.lst")|| die "No puedo abrir el archivo: colors.lst";
@registros=<COLORS>;
@registros = grep(!/^\#/, @registros); 
foreach $hashlinea (@registros){
					@tmp = split(/:/,$hashlinea); # se separa el registo en campos
					# (los : es el delimitador entre la cuenta y la password)
					$hash_colors{$tmp[0]} = $tmp[1]; # se asigna par clave-valor
						};
close (COLORS);
my $colors = $hash_registros{'bgcolor'};
$colors =~ s/\n//g;
my $bgcolor = "#" . $hash_colors{$colors};
$| = 1; #Vaciamos el buffer de escritura lo mas rapido posible<h2></h2>
print("Content-type: text/html\r\n\r\n");	
open (PAGINA,$archivos."/login.pgn")|| die "No puedo abrir el archivo de formulario: login.pgn";
		#Añadimos cada línea de éste en la matriz.
		@lineas=<PAGINA>;
		foreach $linea (@lineas){
				$linea =~ s/<COLOR>/$bgcolor/g;     			
				$linea =~ s/<DOMINIO>/$hash_registros{'dominio'}/g;
     			print ("$linea\n");
     				};
# Cerramos el fichero abierto
close (PAGINA);