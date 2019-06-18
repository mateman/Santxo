#!/usr/bin/perl
#
# Hecho por Pablo Adolfo Cuyeu (cuyeu@hotmail.com)
#

use comun;

# Comienzo del programa principal
%hash_registros=&decodificar_config("/etc/santxo.cfg");
my $host = $hash_registros{'home'};
$host =~ s/\n//g;
$host =~ s/\s*$//g;
$entrada=&metodo_forma();
%datos=&decodificar_forma($entrada);
my $login = $datos{'login'};
my $pwd = $datos{'pwd'};
$pwd =~ s/\n//g;
$login =~ s/\n//g;
my $httpreferer = $ENV{'HTTP_REFERER'};
my $servername = $ENV{'SERVER_NAME'};
my $dirsession = $hash_registros{'session-dir'};
$dirsession =~ s/\n//g;
$dirsession =~ s/\s*$//g;
$tiempo = $hash_registros{'session-tiempo'};
&delete_old($host,$dirsession,$tiempo);
%hash_colors=&decodificar_config($host."/config/colors.lst");
my $colors = $hash_registros{'bgcolor'};
$colors =~ s/\n//g; 
my $bgcolor = "#" .$hash_colors{$colors};
my $dominio = $hash_registros{'dominio'};
my $archivoclave = $hash_registros{'login'};
open (PASSWORD,$archivoclave)|| die "Can't open Password: $!\n";
while ($line = <PASSWORD>) {
			($nombre, $pass) = split(":", $line);
			$pass =~ s/\n//g;
    		$hash_pas{$nombre} = $pass;
}
# Cerramos el fichero abierto
close (PASSWORD);
$encrypted = crypt($pwd, $login);
$| = 1; #Vaciamos el buffer de escritura lo mas rapido posible<h2></h2>
print("Content-type: text/html\r\n\r\n");
if ((exists $hash_pas{$login})&&(($hash_pas{$login}) eq $encrypted))
						{
						my $logs = $hash_registros{'logs'};
						open (LOGS,">> $logs");
						$date = `/bin/date`;
						$date =~ s/\n//g;						
						print (LOGS $login."   ".$date."   inicio de sesion desde  ".$ENV{'REMOTE_ADDR'}."\n");
						close (LOGS);
						$session = `/bin/date "+%s"`;
						$session =~ s/\n//g;
						open (SESSION,">$dirsession$session");
						@valores = ($date, $login,$ENV{'REMOTE_ADDR'},$ENV{'REMOTE_HOST'});
						print (SESSION $date."\n");
						print (SESSION $login."\n");
						print (SESSION $ENV{'REMOTE_ADDR'}."\n");
						print (SESSION $ENV{'REMOTE_HOST'}."\n");						
						close (SESSION); 
						open (PAGINA,$host."/common/form.pgn")|| die "No puedo abrir el archivo: /etc/passwd";						
						#Añadimos cada línea de éste en la matriz.
						@lineas=<PAGINA>;
						foreach $linea (@lineas){
							$linea =~ s/<SESSION>/$session/g;							
							$linea =~ s/<COLOR>/$bgcolor/g;     			
							$linea =~ s/<DOMINIO>/$dominio/g;     						
     						print ("$linea\n");
     						};
						# Cerramos el fichero abierto
						close (PAGINA);}
						else{	open (PAGINA,$host."/common/error.pgn")|| die "No puedo abrir el archivo: /etc/passwd";
								#Añadimos cada línea de éste en la matriz.
								@lineas=<PAGINA>;
								foreach $linea (@lineas){							
									$linea =~ s/<COLOR>/$bgcolor/g;     			     						
     								print ("$linea\n");
     								};
								# Cerramos el fichero abierto
								close (PAGINA);
										};
   



