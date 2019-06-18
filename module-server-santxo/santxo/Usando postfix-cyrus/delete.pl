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

my $adminuser = "cyrus";
my $adminpw = "Debian5";
my $server = "localhost";
my $us = $ARGV[0];

# Borra Mailbox y usuarios de cyrus
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
	    print "ERROR: " . $imap->error . "\n";    
	    exit(-1);
		}

# Verifica la existencia del mailbox
	if (! $imap->listmailbox("user.$us")) {    
	    print "ERROR: Mailbox 'user.$us' No existe \n";    
	    exit(-1);
		}

# Se obtenienen permisos de borrado sobre el mailbox 
	$imap->setaclmailbox("user.$us", "cyrus", "c");
	if ($imap->error) {    
	    print "ERROR: " . $imap->error . "\n";    
	    exit(-1);
		}

# Borrar el mailbox
	$imap->deletemailbox("user.$us");
	if ($imap->error) {    
	    print "ERROR: " . $imap->error . "\n";    
	    exit(-1);
		}
# Borrado del /etc/passwd
	system "sudo /usr/sbin/deluser $us >/dev/null ";
# Borrado del sasl2
	system "/usr/sbin/saslpasswd2 -d $us";