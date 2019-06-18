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
$entrada=&metodo_forma();
%datos=&decodificar_forma($entrada);
$| = 1; #Vaciamos el buffer de escritura lo mas rapido posible;
print("Content-type: text/html\r\n\r\n");
my $file = $hostsession ."$datos{'session'}";
my $server = $datos{'server'};
if (-e $file) 
      {
		$exe = $home."/programs/fileupdate.pl";
		system "perl $exe '$file'";				
		my $cuenta= $datos{'cuenta'};		
		my $ejec = "perl ".$home."/programs/cliente.pl";
		my $val= `$ejec $server 'verificaDNI.pl $cuenta'`;
		$val =~ s/\n//g;		
		if ($val eq "True") {&imprimirpagina($home."/common/advertencia.pgn","Ya existe una cuenta con este DNI","cvalido");
					}
		else {&imprimirpagina($home ."/common/false.pgn","false","cvalido");};
		}
else { &imprimirpagina($home."/common/session.pgn","Vuelva a loguearse","cvalido");};

