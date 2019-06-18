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
my $file = $hostsession .$datos{'session'};
if (-e $file){
		$exe = $home."/programs/fileupdate.pl";
		system "perl $exe '$file'"; 
		if (exists $datos{'server'}){ $server = $datos{'server'};$server =~ s/\n//g;} else {$error == True};		
		if (exists $datos{'cuenta'}){ $cuenta = $datos{'cuenta'};$cuenta =~ s/\n//g;} else {$error == True};
		if (exists $datos{'nombre'}){ $nombre = $datos{'nombre'};$nombre =~ s/\n//g;} else {$error == True};
		if (exists $datos{'sector'}){ $sector = $datos{'sector'};$sector =~ s/\n//g;} else {$error == True};
		if (exists $datos{'tel'}){ $tel = $datos{'tel'};$tel =~ s/\n//g;} else {$error == True};		
		if ((!$cuenta)||(!$nombre)||(!$sector)||(!$tel)|| $error)
				{&imprimirpagina($home ."/common/false.pgn","no se pudo cambiar la cuenta","cvalido");}
		else { my $ejec = "perl ".$home."/programs/cliente.pl";
				my @session = &decodificar_session($file);				
				system "$ejec '$server' 'cambiar.pl \"$nombre\" \"$sector\" \"$tel\" $cuenta'";		 		
				&imprimirpagina($home."/common/true.pgn","cambiada exitosamente","cvalido");
				open (LOGS,">> $config{'logs'}");
				$date = `/bin/date`;
				$date =~ s/\n//g;
				$sess = $session[1];						
				$sess =~ s/\n//g;				
				print (LOGS $sess."   ".$date."   cambio cuenta: ".$cuenta."@".$server." desde  ".$ENV{'REMOTE_ADDR'}."\n");
				close (LOGS);};
		}
else { &imprimirpagina($home."/common/session.pgn","Vuelva a loguearse","cvalido");};
