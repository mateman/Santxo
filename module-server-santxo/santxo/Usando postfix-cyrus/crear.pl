#!/usr/bin/perl 

#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#
#
#   Programa desarrollado por Pablo A Cuyeu (alias Mateman)
#                             cuyeu@hotmail.com
#
my $nombre = $ARGV[0];
my $sector = $ARGV[1];
my $tel = $ARGV[2];
my $cuenta = $ARGV[3];
my $clave = $ARGV[4];
my $adminuser = "cyrus";
my $adminpw = "Debian5";
my $server = "localhost";

sub agregar ($,$){
	my ($us,$pass) =@_;

	use Cyrus::IMAP::Admin;

# Conectando con Cyrus
	$imap = Cyrus::IMAP::Admin->new($server) 
	     || die "Conexion rechazada con el servidor  $server";

	if (! $imap) {    
	    die "Error al crear Objeto de conexion IMAP\n";
		}

	$imap->authenticate(-user => $adminuser, 
	                    -mechanism => "LOGIN", 
	                    -password => $adminpw,);

	if ($imap->error) {    
	    print "ERROR LOGIN IMAP: " . $imap->error . "\n";    
	    exit(-1);
		}


# Crear  el mailbox
	$imap->createmailbox("user.$us");
	if ($imap->error) {    
	    print "ERROR USER: ".$imap->error . "\n";    
	    exit(-1);
		}

# Crear  el mailbox INBOX
	$imap->createmailbox("user.$us.INBOX");
	if ($imap->error) {    
	    print "ERROR USER INBOX: " . $imap->error . "\n";    
	    exit(-1);
		}

# Crear  el mailbox Drafts
	$imap->createmailbox("user.$us.Drafts");
	if ($imap->error) {    
	    print "ERROR USER INBOX: " . $imap->error . "\n";    
	    exit(-1);
		}

# Crear  el mailbox Junk
	$imap->createmailbox("user.$us.Junk");
	if ($imap->error) {    
	    print "ERROR USER INBOX: " . $imap->error . "\n";    
	    exit(-1);
		}

# Crear  el mailbox Sent
	$imap->createmailbox("user.$us.Sent");
	if ($imap->error) {    
	    print "ERROR USER INBOX: " . $imap->error . "\n";    
	    exit(-1);
		}

# Crear  el mailbox Trash
	$imap->createmailbox("user.$us.Trash");
	if ($imap->error) {    
	    print "ERROR USER INBOX: " . $imap->error . "\n";    
	    exit(-1);
		}

# Creo password en sasl2
	system "echo '$pass' |sudo saslpasswd2 -c $us -p >/dev/null";
	}




#Inicio del PROGRAMA

my $val= `cat /etc/passwd |grep "^$cuenta:x:" |wc -l`;
if ($val == 0) { 
		# Damos de alta el usuario en el sistema		
		system "sudo /usr/sbin/adduser --gecos \"$nombre,$sector,$tel\" --disabled-password --disabled-login --no-create-home --home /dev/null --ingroup postfix $cuenta>/dev/null";
		#system "echo '$cuenta:$clave' |sudo /usr/sbin/chpasswd >/dev/null";		
		&agregar($cuenta,$clave);		
		};


