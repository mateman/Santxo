#!/usr/bin/perl 
 use IO::Socket;

$sock = new IO::Socket::INET (PeerAddr => $ARGV[0],
                                 PeerPort => 1234,
                                 Proto    => 'tcp') or die "Error creating socket: $!\n";

recv($sock, $pregunta, 30,undef);
print $sock "$ARGV[1]";
while(<$sock>) {
print $_;
}		
close $sock;
exit;
