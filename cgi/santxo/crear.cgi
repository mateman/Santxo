#!/usr/bin/perl
#
# Hecho por Pablo Adolfo Cuyeu (cuyeu@hotmail.com)
#

use comun;

# Comienzo del programa principal
%config=&decodificar_config("/etc/santxo.cfg");
my $home= $config{'home'};
$home=~ s/\n//g;
$home=~ s/\s*$//g;
$entrada=&metodo_forma();
my $hostsession = $config{'session-dir'};
$hostsession=~ s/\s//g;
my $timesession = $config{'session-tiempo'};
&delete_old($home,$hostsession,$timesession);
%datos=&decodificar_forma($entrada);
$| = 1; #Vaciamos el buffer de escritura lo mas rapido posible;
print("Content-type: text/html\r\n\r\n");	
my $file = $hostsession .$datos{'session'};
if (-e $file) 
      {
		$exe = $home."/programs/fileupdate.pl";
		system "perl $exe '$file'";	
		if (exists $datos{'server'}){ $server = $datos{'server'};$server =~ s/\n//g;$server =~ s/\///g;$server =~ s/://g;$server =~ s/,//g;} else {$error == True};		
		if (exists $datos{'cuenta'}){ $cuenta = $datos{'cuenta'};$cuenta =~ s/\n//g;$cuenta =~ s/\///g;$cuenta =~ s/://g;$cuenta =~ s/,//g;} else {$error == True};
		if (exists $datos{'nombre'}){ $nombre = $datos{'nombre'};$nombre  =~ s/\n//g;$nombre =~ s/\///g;$nombre =~ s/://g;$nombre =~ s/,//g;} else {$error == True};
		if (exists $datos{'DNI'}){ $DNI = $datos{'DNI'};$DNI =~ s/\n//g;$DNI =~ s/\.//g;$DNI =~ s/\s//g;$DNI =~ s/\///g;$DNI =~ s/://g;$DNI =~ s/,//g;} else {$error == True};
		if (exists $datos{'sector'}){ $sector = $datos{'sector'};$sector =~ s/\n//g;$sector =~ s/\///g;$sector =~ s/://g;$sector =~ s/,//g;} else {$error == True};
		if (exists $datos{'tel'}){ $tel = $datos{'tel'};$tel =~ s/\n//g;$tel =~ s/\///g;$tel =~ s/://g;$tel =~ s/,//g;} else {$error == True};
		if (exists $datos{'clave'}){ $pass = $datos{'clave'};$pass =~ s/\n//g;} else {$error == True};
		if (exists $datos{'newclave'}){ $newpass = $datos{'newclave'};$newpass =~ s/\n//g;} else {$error == True};		
		if ((!$cuenta)||(!$nombre)||(!$DNI)||(!$sector)||(!$tel)||(!$pass)||(!$newpass)||$error||!($pass==$newpass))
			{&imprimirpagina($home ."/common/false.pgn","no se pudo crear la cuenta","cvalido");}
		else {
				my @session = &decodificar_session($file); 
				my $dire="perl $home/programs/cliente.pl";				
				$DNI =~ s/\.*\-*\s*//g;
				system "$dire '$server' 'crear.pl \"$nombre\" \"$sector\" \"$tel\" \"$DNI\" \"$cuenta\" \"$pass\"'";
		 		&imprimirpagina($home."/common/true.pgn","creada exitosamente","cvalido");
				open (LOGS,">> $config{'logs'}");
				$date = `/bin/date`;
				$date =~ s/\n//g;
				$sess = $session[1];						
				$sess =~ s/\n//g;				
				print (LOGS $sess."   ".$date."   creo cuenta: ".$cuenta."@".$server." para ".$DNI." desde  ".$ENV{'REMOTE_ADDR'}."\n");
				close (LOGS);
			};}
else { &imprimirpagina($home."/common/session.pgn","Vuelva a loguearse","cvalido");};
