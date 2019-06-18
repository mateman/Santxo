#!/usr/bin/perl
#
# Hecho por Pablo Adolfo Cuyeu (cuyeu@hotmail.com)
#

use comun;

# Comienzo del programa principal
%config=&decodificar_config("/etc/santxo.cfg");
my $home= $config{'home'};
$home=~ s/\n//g;
$entrada=&metodo_forma();
%datos=&decodificar_forma($entrada);
my $hostsession = $config{'session-dir'};
$hostsession=~ s/\s//g;
my $timesession = $config{'session-tiempo'};
&delete_old($home,$hostsession,$timesession);
$| = 1; #Vaciamos el buffer de escritura lo mas rapido posible;
print("Content-type: text/html\r\n\r\n");
my $file = $hostsession.$datos{'session'};
if (-e $file) 
      {
		$exe = $home."/programs/fileupdate.pl";
		system "perl $exe '$file'";	
		my $cuenta= $datos{'cuenta'};
		my $server = $datos{'server'};
		my $dire="perl ".$home."/programs";
		my $val = `$dire/cliente.pl '$server' 'verifica.pl $cuenta'`;
		$val =~ s/\n//g;		
		if ($val eq "True") 
				{system "$dire/cliente.pl '$server' 'delete.pl $cuenta'"; 
		 		&imprimirpagina($home."/common/true.pgn","borrada exitosamente","cvalido");
				my @session = &decodificar_session($file);		 		
		 		open (LOGS,">> $config{'logs'}");
				$date = `/bin/date`;
				$date =~ s/\n//g;
				$sess = $session[1];						
				$sess =~ s/\n//g;				
				print (LOGS $sess."   ".$date."   borro cuenta: ".$cuenta."@".$server." desde  ".$ENV{'REMOTE_ADDR'}."\n");
				close (LOGS);}
		else {&imprimirpagina($home ."/common/false.pgn","no se pudo borrar la cuenta","cvalido");};
		}
else { &imprimirpagina($home."/common/session.pgn","Vuelva a loguearse","cvalido");};
