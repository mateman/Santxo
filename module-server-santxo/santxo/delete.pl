#!/usr/bin/perl 
my $nombre = $ARGV[0];
system "/usr/sbin/userdel $nombre >/dev/null ";