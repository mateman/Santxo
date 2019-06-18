#!/usr/bin/perl
#
# Hecho por Pablo Adolfo Cuyeu (cuyeu@hotmail.com)
#

use comun;

# Comienzo del programa principal
%config=&decodificar_config("/etc/santxo.cfg");
my $host= $config{'home'};
$host=~ s/\n//g;
$host=~ s/\s//g;
my $hostsession = $config{'session-dir'};
$hostsession=~ s/\s//g;
$hostsession=~ s/\n//g;
my $timesession = $config{'session-tiempo'};
$exe = $host."/programs/filedate.pl";
&delete_old($host,$hostsession,$timesession);
$entrada=&metodo_forma();
%datos=&decodificar_forma($entrada);
my $path="../../santxo/imagenes";
my $file = $hostsession ."$datos{'session'}";
my $server = $datos{'server'};
$| = 1; #Vaciamos el buffer de escritura lo mas rapido posible<h2></h2>
print("Content-type: text/html\r\n\r\n");	
if (-e $file) 
      {
		$exe = $host."/programs/fileupdate.pl";
		system "perl $exe '$file'";
		#Tomamos cada linea del registro 
		my $valor = `perl $host/programs/cliente.pl $server listar.pl`;
		my @datos =split(/\n/,$valor);
		open (EDI,$host."/common/listar.pgn")|| die "No puedo abrir el archivo: listar.pgn";
		@lineas=<EDI>;
		foreach $linea (@lineas){
			if (($linea =~ m/<TR>/)||($linea =~ m/<TD>/)||($linea =~ m/<TH>/)){		
				foreach $dato (@datos){
				my $ltemp = $linea;		
				($cuenta,$nombre,$sector,$tel,$DNI)=split(/\,/,$dato);		
				$ltemp =~ s/<PATH>/$path/g;
				$ltemp =~ s/<CUENTA>/$cuenta/g;		
				$ltemp =~ s/<NOMBRE>/$nombre/g;
				$ltemp =~ s/<DNI>/$DNI/g;     						
				$ltemp =~ s/<SECTOR>/$sector/g;
				$ltemp =~ s/<TEL>/$tel/g;     						
     			print ("$ltemp\n");
    		};}
			else {print ("$linea\n");};
		};
		close (EDI);
}
else { &imprimirpagina($host."/common/session.pgn","Vuelva a loguearse","valido");};

