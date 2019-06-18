#!/usr/bin/perl 
my $cuenta = $ARGV[0];
my $clave = $ARGV[1];
system "echo '$cuenta:$clave' |/usr/sbin/chpasswd >/dev/null";