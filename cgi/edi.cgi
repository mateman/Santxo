#!/usr/bin/perl
#
# Hecho por Pablo Adolfo Cuyeu (cuyeu@hotmail.com)
#

use comun;
				
# Comienzo del programa principal
%hash_registros=&decodificar_config("/etc/santxo.cfg");
my $host = $hash_registros{'home'};
$host =~ s/\n//g;
$entrada=&metodo_forma();
%datos=&decodificar_forma($entrada);
my $hostsession = $hash_registros{'session-dir'};
$hostsession=~ s/\s//g;
my $timesession = $hash_registros{'session-tiempo'};
&delete_old($host,$hostsession,$timesession);
$| = 1; #Vaciamos el buffer de escritura lo mas rapido posible<h2></h2>
print("Content-type: text/html\r\n\r\n");
my $file = $hostsession ."$datos{'session'}";
my $server = $datos{'server'};
if (-e $file) 
      {
		$exe = $home."/programs/fileupdate.pl";
		system "perl $exe '$file'";	
		my $edcuenta = $datos{'cuenta'};
		$edcuenta =~ s/\n//g;
		my $ope = $datos{'operacion'};
		$ope =~ s/\n//g;		
		my $val = `perl $host/programs/cliente.pl '$server' 'verifica.pl $edcuenta'`;
		$val =~ s/\n//g;		
		if ($val eq "True") 
				{
						my $valores = `perl $host/programs/cliente.pl '$server' 'edi.pl $edcuenta'`; 
						my $estado = ($ope eq "editar");
						($nombre,$sector,$tel)=split (/\,/,$valores);						
						if ($estado){ open (EDI,$host."/common/edit.pgn")|| die "No puedo abrir el archivo: /etc/passwd";
											$var = 'evalido';}						
						else {open (EDI,$host."/common/ver.pgn")|| die "No puedo abrir el archivo: /etc/passwd";
								$var = 'vvalido';};
						#Añadimos cada línea de éste en la matriz.
						@lineas=<EDI>;
						foreach $linea (@lineas){							
							$linea =~ s/<VARIABLE>/$var/g;							
							$linea =~ s/<NOMBRE>/$nombre/g;												     			
							$linea =~ s/<SECTOR>/$sector/g;
							$linea =~ s/<TEL>/$tel/g;     						
     						print ("$linea\n");
     						};
						# Cerramos el fichero abierto
						close (EDI);}
						else{&imprimirpagina($host."/common/editerror.pgn","Puede que esta cuenta no exista","vvalido");
										};
		}
else { &imprimirpagina($host."/common/session.pgn","Vuelva a loguearse",'vvalido');};

   



