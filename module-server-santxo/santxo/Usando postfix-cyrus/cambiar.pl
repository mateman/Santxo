#!/usr/bin/perl 
my $nombre = $ARGV[0];
my $sector = $ARGV[1];
my $tel = $ARGV[2];
my $cuenta = $ARGV[3];
system "sudo /usr/bin/chfn -f \"$nombre\" -r \"$sector\" -w \"$tel\" $cuenta ";