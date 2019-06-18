#!/usr/bin/perl 
my $nombre = $ARGV[0];
my $sector = $ARGV[1];
my $tel = $ARGV[2];
my $cuenta = $ARGV[3];
system "/usr/bin/chfn -f \"$nombre\" -o \"$sector\" -p \"$tel\" $cuenta >/dev/null";