#!/usr/bin/perl 
my $nombre = $ARGV[0];
my $sector = $ARGV[1];
my $tel = $ARGV[2];
my $cuenta = $ARGV[3];
my $clave = $ARGV[4];
my $val= `cat /etc/passwd |grep "^$cuenta:x:" |wc -l`;
if ($val == 0) { 
		system "sudo /usr/sbin/adduser $cuenta -s /sbin/nologin >/dev/null";
		system "echo '$cuenta:$clave' |sudo /usr/sbin/chpasswd >/dev/null";		
		system "/usr/bin/chfn -f \"$nombre\" -o \"$sector\" -p \"$tel\" $cuenta >/dev/null";
		};
