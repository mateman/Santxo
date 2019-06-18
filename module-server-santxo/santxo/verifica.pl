#!/usr/bin/perl 

# La siguiente linea hace lo mismo que el foreach salvo que dejamos la tarea de busqueda al sistema
#$val= `cat /etc/passwd |grep ^$usu.:x: |wc -l`;

@registros=`/bin/cat /etc/passwd`;
#@registros=`/usr/sbin/sasldblistusers2`;
#        Tomamos cada linea del registro que contiene nombreUser@mail: user passwd

        foreach $linea (@registros)
  			      {
#        Y esta linea la descomponemos en un vector con dos campos, user y resto
         			@usuario=split(/:/,$linea);
         			if (($ARGV[0] eq @usuario[0])&& (@usuario[2] >= 500)) {
							$val++};
                		};

if ($val > 0) {print "True"} else {print "False"};