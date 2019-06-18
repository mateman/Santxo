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
		if (exists $datos{'sourcecuenta'}){ $sourcecuenta = $datos{'sourcecuenta'};$sourcecuenta =~ s/\n//g;} else {$error == True};
		if (exists $datos{'sourcehost'}){ $sourcehost = $datos{'sourcehost'};$sourcehost =~ s/\n//g;} else {$error == True};
		if (exists $datos{'sourcepass'}){ $sourcepass = $datos{'sourcepass'};$sourcepass =~ s/\n//g;} else {$error == True};
		if (exists $datos{'destinocuenta'}){ $destinocuenta = $datos{'destinocuenta'};$destinocuenta =~ s/\n//g;} else {$error == True};
		if (exists $datos{'destinohost'}){ $destinohost = $datos{'destinohost'};$destinohost =~ s/\n//g;} else {$error == True};
		if (exists $datos{'destinopass'}){ $destinopass = $datos{'destinopass'};$destinopass =~ s/\n//g;} else {$error == True};		
		if ((!$sourcecuenta)||(!$sourcehost)||(!$sourcepass)||(!$destinocuenta)||(!$destinohost)||(!$destinopass)|| $error)
				{&imprimirpagina($home ."/common/false.pgn","no se pudo cambiar la cuenta","cvalido");}
		else { my $ejec = "perl ".$home."/programs/imapcopy.pl";
				my @session = &decodificar_session($file);								
				$verifica = `$ejec -S $sourcehost/$sourcecuenta/$sourcepass -D $destinohost/$destinocuenta/$destinopass `;		 		
				$verifica =~ s/\n//g;
				$verifica =~ s/\s//g;				
				if (length($verifica)== 0) {&imprimirpagina($home."/common/true.pgn","$datos{'sourcecuenta'} copiada exitosamente","cvalido");
				open (LOGS,">> $config{'logs'}");
				$date = `/bin/date`;
				$date =~ s/\n//g;
				$sess = $session[1];						
				$sess =~ s/\n//g;				
				print (LOGS $sess."   ".$date."   copio cuenta: ".$sourcecuenta."@".$sourcehost." a ".$destinocuenta."@".$destinohost." desde  ".$ENV{'REMOTE_ADDR'}."\n");
				close (LOGS);}
				else {&imprimirpagina($home ."/common/false.pgn","no se pudo cambiar la cuenta","cvalido");};
		
		};
}
else { &imprimirpagina($home."/common/session.pgn","Vuelva a loguearse","cvalido");};
