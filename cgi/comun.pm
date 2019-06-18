#Modulo con programas en comun entre todos los cgi's que compone este aplicativo

# La siguiente rutina determina el tipo de metodo empleado
# en el envio de los datos
sub metodo_forma {
						my($metodo)=$ENV{'REQUEST_METHOD'};
						my($entrada);
						#Validamos primero el tipo de codificacion
						if (($ENV{'CONTENT_TYPE'} !~ /^application\/x-www-form-urlencoded/i) && ($ENV{'CONTENT_TYPE'} ne '')) 
									{
										print("Content-type: text/html\r\n\r\n");
										print("<html><head><title>Error en CGI</title></head>\n");
										print("<body bgcolor=#FFFFFF>\n");
										print("<H1>Error: Codificacion desconocida\n</H1>");
										print("<H2>Soporta: application\/x-www-form-urlencoded\n</H2>");
										print("</body></html>\n");
										exit;
									}
						$metodo =~ tr/A-Z/a-z/; #Convierta la respuesta a minusculas
						#El metodo es POST y tiene longitud > 0
						if (($metodo eq "post") && ($ENV{'CONTENT_LENGTH'} > 0)) 
									{
										read(STDIN,$entrada,$ENV{'CONTENT_LENGTH'});
										return($entrada);
									} else { #Metodo desconocido o valor nulo
												print("Content-type: text/html\r\n\r\n");
												print("<html><head><title>Error en CGI</title></head>\n");
												print("<body bgcolor=#FFFFFF>\n");
												print("<H1>Error: Metodo desconocido o valor nulo\n</H1>");
												print("<H2>Soporta: Method=POST\n</H2>");
												print("</body></html>\n");
												exit;
											}
			} #Fin metodo_forma()

# La siguiente rutina decodifica la entrada y la guarda en
# un arreglo asociativo
sub decodificar_forma($) {
					my($BUENOS_CARACTERES)='-a-zA-Z0-9_.@ '; #Caracteres validos en los datos
					my($entrada)=@_;
					my(%pares,$clave,$valor);
					$entrada =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("c",hex($1))/ge; #Convierto a alfanumerico los caracteres en hexadecimal
					@pares=split('&',$entrada); #Separo cada par y lo guardo en un arreglo
					foreach $par (@pares) { # proceso cada par en pares
								($clave,$valor)=split(/=/,$par); #Guarde clave,valor usando la busqueda anterior
								$valor =~ s/\+/ /g; #Cambie + por espacio en toda la cadena
								# Seguridad  en caracteres,segun aviso del Cern en
								# http://geek-girl.com/bugtraq/1997_4/0232.html
								$clave =~ s/[^$BUENOS_CARACTERES]/_/go;
								$valor =~ s/[^$BUENOS_CARACTERES]/_/go;
								#Finalmente construya el arreglo asociativo
								$pares{$clave}=$valor;
												}
					return(%pares);
									} # Fin Decodificar_forma()
	

#Rutina para cargar la configuracion del sistema
											
sub decodificar_config($) {
				my ($arch) = @_;
				$arch =~ s/\n//g;				
				open (CONFIG,$arch)|| die "No puedo abrir el archivo: $user";
				my @registros=<CONFIG>;
				@registros = grep(!/^\#/, @registros);
				@registros= sort @registros; 				
				my %hash_registros;				
				foreach $hashlinea (@registros){
							my @tmp = split(/:/,$hashlinea); # se separa el registo en campos
							#los : es el delimitador entre el tipo de dato y y el dato en concreto
							$hash_registros{$tmp[0]} = $tmp[1]; # se asigna par clave-valor
							};
				# Cerramos el fichero abierto
				close (CONFIG);
				return(%hash_registros);
				} # Fin Decodificar_Config

#Rutina para cargar valores de session para logs

sub decodificar_session($) {
				my ($arch) = @_;
				$arch =~ s/\n//g;				
				open (SESS,$arch)|| die "No puedo abrir el archivo: $arch";
				my @registros=<SESS>;
				close (SESS);
				return(@registros);
				} # Fin Decodificar_session				


#Rutina para imprimir pagina

sub imprimirpagina($,$,$){	
				my ($arch,$mensaje,$var) = @_;
				$arch =~ s/\n//g;				
				open (IMP,$arch)|| die "No puedo abrir el archivo: $arch";
				my @registros=<IMP>;
				close (IMP);
				foreach $linea (@registros){
					$linea =~ s/<MENSAJE>/$mensaje/g;
					$linea =~ s/<VARIABLE>/$var/g;					
					print $linea;};
					} #Fin de imprimir

#Rutina para borrar los archivos de session viejos

sub delete_old($,$,$){
				my ($h,$hs,$t) = @_;
				$exe = $h ."/programs/filedate.pl";
				system "perl $exe $hs $t";
				} #Fin de delete_old

1;