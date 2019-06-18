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
$entrada=&metodo_forma();
%datos=&decodificar_forma($entrada);
$| = 1; #Vaciamos el buffer de escritura lo mas rapido posible;
print("Content-type: text/html\r\n\r\n");
my $server = $datos{'server'};
$exe = $home."/programs/fileupdate.pl";
system "perl $exe '$file'";				
my $cuenta= $datos{'cuenta'};		
my $ejec = "perl ".$home."/programs/cliente.pl";
my $val= `$ejec $server 'verifica.pl $cuenta'`;
$val =~ s/\n//g;		
print ($val);

