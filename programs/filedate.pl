#!/usr/bin/perl 
my $dir = $ARGV[0];
$dir=~ s/\n//g;
$dir=~ s/\s//g;
my $var = ` ls --time-style=+%s -tl $ARGV[0]`;
@registros = split (/\n/,$var);
my $date = `date "+%s"`;
my $e = shift @registros;
@registros= grep {($atriv,$n,$uid,$guid,$vol,$df,$otro) =split(/\s+/,$_); int($df) < (int($date) - int($ARGV[1]) * 60); } @registros;
foreach $linea (@registros)
 { ($atriv,$n,$uid,$guid,$vol,$df,$session,$otro) =split(/\s+/,$linea);
	$dirses = $dir.$session;	
 	system "/bin/rm '$dirses'";
	};
