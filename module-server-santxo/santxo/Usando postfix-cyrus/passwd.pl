#!/usr/bin/perl 
my $cuenta = $ARGV[0];
my $clave = $ARGV[1];
system "echo '$clave' |sudo saslpasswd2 -c $cuenta -p >/dev/null";
