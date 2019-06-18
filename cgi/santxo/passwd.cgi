#!/usr/bin/perl
#
# Hecho por Pablo Adolfo Cuyeu (cuyeu@hotmail.com)
#

use comun;

# Comienzo del programa principal
%config=&decodificar_config("/etc/santxo.cfg");
my $home= $config{'home'};
$home=~ s/\n//g;
my $hostsession = $config{'session-dir'};
$hostsession=~ s/\s//g;
my $timesession = $config{'session-tiempo'};
$exe = $home ."/programs/filedate.pl";
system "$exe $hostsession $timesession";
$entrada=&metodo_forma();
%datos=&decodificar_forma($entrada);
$| = 1; #Vaciamos el buffer de escritura lo mas rapido posible;
print("Content-type: text/html\r\n\r\n");
my $file = $hostsession.$datos{'session'};
my $server = $datos{'server'};
if (-e $file) 
      {
		$exe = $home."/programs/fileupdate.pl";
		system "perl $exe '$file'";	
		my $cuenta= $datos{'cuenta'};
		my $clave= $datos{'clave'};
		my $dire="perl ".$home."/programs";
		my $val = `$dire/cliente.pl '$server' 'verifica.pl $cuenta'`;
		$val =~ s/\n//g;		
		if ($val eq "True") 
				{if ($clave eq ($datos{'newclave'}))
					{
					system "$dire/cliente.pl '$server' 'passwd.pl $cuenta $clave'"; 
		 			&imprimirpagina($home."/common/true.pgn","Contrase\&ntilde;a cambiada exitosamente");
		 			my @session = &decodificar_session($file);		 		
			 		open (LOGS,">> $config{'logs'}");
					$date = `/bin/date`;
					$date =~ s/\n//g;
					$sess = $session[1];						
					$sess =~ s/\n//g;				
					print (LOGS $sess."   ".$date."  cambio clave de cuenta: ".$cuenta."@".$server." desde  ".$ENV{'REMOTE_ADDR'}."\n");
					close (LOGS);}
				else {&imprimirpagina($home ."/common/false.pgn","cambio de contrase\&ntilde;a","cvalido");}; 
				}
		else {&imprimirpagina($home ."/common/false.pgn","Cuenta no valida","cvalido");};
		}
else { &imprimirpagina($home."/common/session.pgn","Vuelva a loguearse","cvalido");};

