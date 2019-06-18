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
$hostsession=~ s/\s*$//g;
my $timesession = $config{'session-tiempo'};
&delete_old($home,$hostsession,$timesession);
$| = 1; #Vaciamos el buffer de escritura lo mas rapido posible;
print("Content-type: text/html\r\n\r\n");
my $file = $hostsession.$datos{'session'};
if (-e $file) 
      {
      my @session = &decodificar_session($file);		 		
		open (LOGS,">> $config{'logs'}");
		$date = `/bin/date`;
		$date =~ s/\n//g;
		$sess = $session[1];						
		$sess =~ s/\n//g;				
		print (LOGS $sess."   ".$date."   cerro session desde  ".$ENV{'REMOTE_ADDR'}."\n");
		close (LOGS);
		$exe = $home."/programs/fileremove.pl";
		system "perl $exe '$file'";				
		&imprimirpagina($home ."/common/false.pgn","false");
		}
else { &imprimirpagina($home."/common/session.pgn","Vuelva a loguearse");};

