#!/usr/bin/perl

# $Header: /mhub4/sources/imap-tools/imapcopy.pl,v 1.8 2009/11/07 17:21:22 rick Exp $

#######################################################################
#   Program name    imapcopy.pl                                       #
#   Written by      Rick Sanders                                      #
#                                                                     #
#   Description                                                       #
#                                                                     #
#   imapcopy is a utility for copying a user's messages from one      #
#   IMAP server to another.                                           #
#                                                                     #
#   imapcopy is called like this:                                     #
#      ./imapcopy -S host1/user1/password1 -D host2/user2/password2   # 
#                                                                     #
#   Optional arguments:                                               #
#	-d debug                                                      #
#       -I show IMAP protocol exchanges                               #
#       -L logfile                                                    #
#       -m mailbox list (copy only certain mailboxes,see usage notes) #
#       -r reset the \DELETE flag on copied messages                  #
#       -p <root mailbox> put copied mailboxes under a root mbx       #
#       -M <file> mailbox mapping (eg, src:inbox -> dst:inbox_copied) #
#######################################################################

use Socket;
use FileHandle;
use Fcntl;
use Getopt::Std;
use IO::Socket;

#################################################################
#            Main program.                                      #
#################################################################

   init();

   #  Get list of all messages on the source host
   #
   connectToHost($sourceHost, \$src)   or exit;
   login($sourceUser,$sourcePwd, $src) or exit;
   namespace( $src, \$srcPrefix, \$srcDelim );

   connectToHost( $destHost, \$dst ) or exit;
   login( $destUser,$destPwd, $dst ) or exit;
   namespace( $dst, \$dstPrefix, \$dstDelim );

   @mbxs = getMailboxList($sourceUser, $src);
   map_mbx_names( \%mbx_map, $srcDelim, $dstDelim );

   $total=0;
   foreach $srcmbx ( @mbxs ) {
        $dstmbx = mailboxName( $srcmbx,$srcPrefix,$srcDelim,$dstPrefix,$dstDelim );
        createMbx( $dstmbx, $dst ) unless mbxExists( $dstmbx, $dst);
        selectMbx( $dstmbx, $dst );
        Log("Copying messages in $srcmbx mailbox") if $debug;
	getMsgList( $srcmbx, \@msgs, $src ); 

        if ( $#msgs == -1 ) {
           Log("$srcmbx mailbox is empty");
           next;
        }

        $copied=0;
        foreach $_ ( @msgs ) {
           ($msgnum,$date,$flags) = split(/\|/, $_);
           $message = fetchMsg( $msgnum, $srcmbx, $src );
           next unless $message;
           $copied++ if insertMsg( $dst, $dstmbx, *message, $flags, $date );
        }
        $total += $copied;
        if ( $use_utf7 ) {
           $dstmbx = Unicode::IMAPUtf7::imap_utf7_decode( $dstmbx );
        }
        Log("Copied $copied messages to $dstmbx");
   }

   Log("Copied $total total messages");
   logout( $src );
   logout( $dst );

   exit;


sub init {

   $os = $ENV{'OS'};

   processArgs();

   if ($timeout eq '') { $timeout = 60; }

   #  Open the logFile
   #
   if ( $logfile ) {
      if ( !open(LOG, ">> $logfile")) {
         print STDOUT "Can't open $logfile: $!\n";
      } 
      select(LOG); $| = 1;
   }
   Log("$0 starting");

   #  Determine whether we have SSL support via openSSL and IO::Socket::SSL
   $ssl_installed = 1;
   eval 'use IO::Socket::SSL';
   if ( $@ ) {
      $ssl_installed = 0;
   }
}

#
#  sendCommand
#
#  This subroutine formats and sends an IMAP protocol command to an
#  IMAP server on a specified connection.
#

sub sendCommand {

my $fd = shift;
my $cmd = shift;

    print $fd "$cmd\r\n";

    Log (">> $cmd") if $showIMAP;
}

#
#  readResponse
#
#  This subroutine reads and formats an IMAP protocol response from an
#  IMAP server on a specified connection.
#

sub readResponse {
    
my $fd = shift;

    $response = <$fd>;
    chop $response;
    $response =~ s/\r//g;
    push (@response,$response);
    Log ("<< $response") if $showIMAP;1
}

#
#  Log
#
#  This subroutine formats and writes a log message to STDERR.
#

sub Log {
 
my $str = shift;

   #  If a logfile has been specified then write the output to it
   #  Otherwise write it to STDOUT

   if ( $logfile ) {
      ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime;
      if ($year < 99) { $yr = 2000; }
      else { $yr = 1900; }
      $line = sprintf ("%.2d-%.2d-%d.%.2d:%.2d:%.2d %s\n",
		     $mon + 1, $mday, $year + $yr, $hour, $min, $sec,$str);
      print LOG "$line";
   } 
   print STDOUT "$line";

}


sub createMbx {

my $mbx  = shift;
my $conn = shift;

   #  Create the mailbox if necessary
   
   sendCommand ($conn, "1 CREATE \"$mbx\"");
   while ( 1 ) {
      readResponse ($conn);
      last if $response =~ /^1 OK/i;
      last if $response =~ /already exists/i;
      if ( $response =~ /^1 NO|^1 BAD/ ) {
         Log ("Error creating $mbx: $response");
         last;
      }
      
   } 

}

#  insertMsg
#
#  This routine inserts a message into a user's mailbox
#
sub insertMsg {

local ($conn, $mbx, *message, $flags, $date) = @_;
local ($lenx);

   Log("   Inserting message") if $debug;
   $lenx = length($message);
   $totalBytes = $totalBytes + $lenx;
   $totalMsgs++;

   $flags = flags( $flags );

   sendCommand ($conn, "1 APPEND \"$mbx\" ($flags) \"$date\" \{$lenx\}");
   readResponse ($conn);
   if ( $response !~ /^\+/ ) {
       Log ("unexpected APPEND response: $response");
       # next;
       push(@errors,"Error appending message to $mbx for $user");
       return 0;
   }

   print $conn "$message\r\n";

   undef @response;
   while ( 1 ) {
       readResponse ($conn);
       if ( $response =~ /^1 OK/i ) {
	   last;
       }
       elsif ( $response !~ /^\*/ ) {
	   Log ("unexpected APPEND response: $response");
	   # next;
	   return 0;
       }
   }

   return 1;
}

#  Make a connection to a IMAP host

sub connectToHost {

my $host = shift;
my $conn = shift;

   Log("Connecting to $host") if $debug;
   
   ($host,$port) = split(/:/, $host);
   $port = 143 unless $port;

   # We know whether to use SSL for ports 143 and 993.  For any
   # other ones we'll have to figure it out.
   $mode = sslmode( $host, $port );

   if ( $mode eq 'SSL' ) {
      unless( $ssl_installed == 1 ) {
         warn("You must have openSSL and IO::Socket::SSL installed to use an SSL connection");
         Log("You must have openSSL and IO::Socket::SSL installed to use an SSL connection");
         exit;
      }
      Log("Attempting an SSL connection") if $debug;
      $$conn = IO::Socket::SSL->new(
         Proto           => "tcp",
         SSL_verify_mode => 0x00,
         PeerAddr        => $host,
         PeerPort        => $port,
      );

      unless ( $$conn ) {
        $error = IO::Socket::SSL::errstr();
        Log("Error connecting to $host: $error");
        exit;
      }
   } else {
      #  Non-SSL connection
      Log("Attempting a non-SSL connection") if $debug;
      $$conn = IO::Socket::INET->new(
         Proto           => "tcp",
         PeerAddr        => $host,
         PeerPort        => $port,
      );

      unless ( $$conn ) {
        Log("Error connecting to $host:$port: $@");
        warn "Error connecting to $host:$port: $@";
        exit;
      }
   } 
   Log("Connected to $host on port $port");

}

sub sslmode {

my $host = shift;
my $port = shift;
my $mode;

   #  Determine whether to make an SSL connection
   #  to the host.  Return 'SSL' if so.

   if ( $port == 143 ) {
      #  Standard non-SSL port
      return '';
   } elsif ( $port == 993 ) {
      #  Standard SSL port
      return 'SSL';
   }
      
   unless ( $ssl_installed ) {
      #  We don't have SSL installed on this machine
      return '';
   }

   #  For any other port we need to determine whether it supports SSL

   my $conn = IO::Socket::SSL->new(
         Proto           => "tcp",
         SSL_verify_mode => 0x00,
         PeerAddr        => $host,
         PeerPort        => $port,
    );

    if ( $conn ) {
       close( $conn );
       $mode = 'SSL';
    } else {
       $mode = '';
    }

   return $mode;
}

#  trim
#
#  remove leading and trailing spaces from a string
sub trim {
 
local (*string) = @_;

   $string =~ s/^\s+//;
   $string =~ s/\s+$//;

   return;
}


#  login
#
#  login in at the source host with the user's name and password
#
sub login {

my $user = shift;
my $pwd  = shift;
my $conn = shift;

   sendCommand ($conn, "1 LOGIN $user $pwd");
   while (1) {
	readResponse ( $conn );
	last if $response =~ /^1 OK/i;
	if ($response =~ /^1 NO|^1 BAD/i) {
           Log ("unexpected LOGIN response: $response");
           return 0;
	}
   }
   Log("Logged in as $user") if $debug;

   return 1;
}


#  logout
#
#  log out from the host
#
sub logout {

my $conn = shift;

   undef @response;
   sendCommand ($conn, "1 LOGOUT");
   while ( 1 ) {
	readResponse ($conn);
	if ( $response =~ /^1 OK/i ) {
		last;
	}
	elsif ( $response !~ /^\*/ ) {
		Log ("unexpected LOGOUT response: $response");
		last;
	}
   }
   close $conn;
   return;
}

#  getMailboxList
#
#  get a list of the user's mailboxes from the source host
#
sub getMailboxList {

my $user = shift;
my $conn = shift;
my @mbxs;
my @mailboxes;

   #  Get a list of the user's mailboxes
   #
  if ( $mbxList ) {
      #  The user has supplied a list of mailboxes so only processes
      #  the ones in that list
      @mbxs = split(/,/, $mbxList);
      foreach $mbx ( @mbxs ) {
         trim( *mbx );
         push( @mailboxes, $mbx );
      }
      return @mailboxes;
   }

   if ($debug) { Log("Get list of user's mailboxes",2); }

   sendCommand ($conn, "1 LIST \"\" *");
   undef @response;
   while ( 1 ) {
	readResponse ($conn);
	if ( $response =~ /^1 OK/i ) {
		last;
	}
	elsif ( $response !~ /^\*/ ) {
		Log ("unexpected response: $response");
		return 0;
	}
   }

   undef @mbxs;

   for $i (0 .. $#response) {
        $response[$i] =~ s/\s+/ /;
        if ( $response[$i] =~ /"$/ ) {
           $response[$i] =~ /\* LIST \((.*)\) "(.+)" "(.+)"/i;
           $mbx = $3;
        } elsif ( $response[$i] =~ /\* LIST \((.*)\) NIL (.+)/i ) {
           $mbx= $2;
        } else {
           $response[$i] =~ /\* LIST \((.*)\) "(.+)" (.+)/i;
           $mbx = $3;
        }
	$mbx =~ s/^\s+//;  $mbx =~ s/\s+$//;

	if ($response[$i] =~ /NOSELECT/i) {
		if ($debug) { Log("$mbx is set NOSELECT,skip it",2); }
		next;
	}
	if (($mbx =~ /^\#/) && ($user ne 'anonymous')) {
		#  Skip public mbxs unless we are migrating them
		next;
	}
	if ($mbx =~ /^\./) {
		# Skip mailboxes starting with a dot
		next;
	}
	push ( @mbxs, $mbx ) if $mbx ne '';
   }

   if ( $mbxList ) {
      #  The user has supplied a list of mailboxes so only processes
      #  those
      @mbxs = split(/,/, $mbxList);
   }

   return @mbxs;
}

#  getMsgList
#
#  Get a list of the user's messages in the indicated mailbox on
#  the source host
#
sub getMsgList {

my $mailbox = shift;
my $msgs    = shift;
my $conn    = shift;
my $seen;
my $empty;
my $msgnum;
my $from;
my $flags;

   trim( *mailbox );
   sendCommand ($conn, "1 EXAMINE \"$mailbox\"");
   undef @response;
   $empty=0;
   while ( 1 ) {
	readResponse ( $conn );
	if ( $response =~ / 0 EXISTS/i ) { $empty=1; }
	if ( $response =~ /^1 OK/i ) {
		# print STDERR "response $response\n";
		last;
	}
	elsif ( $response !~ /^\*/ ) {
		Log ("unexpected response: $response");
		# print STDERR "Error: $response\n";
		return 0;
	}
   }

   sendCommand ( $conn, "1 FETCH 1:* (uid flags internaldate body[header.fields (From Date)])");
   
   undef @response;
   while ( 1 ) {
	readResponse ( $conn );
	if ( $response =~ /^1 OK/i ) {
		# print STDERR "response $response\n";
		last;
	} 
        last if $response =~ /^1 NO|^1 BAD/;
   }

   @msgs  = ();
   $flags = '';
   for $i (0 .. $#response) {
	last if $response[$i] =~ /^1 OK FETCH complete/i;

        if ( $response[$i] =~ /^From: (.+)/i ) {
           $from = $1;
        }

        if ($response[$i] =~ /FLAGS/) {
           #  Get the list of flags
           $response[$i] =~ /FLAGS \(([^\)]*)/;
           $flags = $1;
           $flags =~ s/\\Recent//;
        }

        if ( $response[$i] =~ /INTERNALDATE/) {
           $response[$i] =~ /INTERNALDATE (.+) BODY/i;
           # $response[$i] =~ /INTERNALDATE "(.+)" BODY/;
           $date = $1;
           
           $date =~ /"(.+)"/;
           $date = $1;
           $date =~ s/"//g;
        }

        # if ( $response[$i] =~ /\* (.+) [^FETCH]/ ) {
        if ( $response[$i] =~ /\* (.+) FETCH/ ) {
           ($msgnum) = split(/\s+/, $1);
        }

Log("msgnum $msgnum");
Log("from   $from");
Log("date   $date");

        if ( $msgnum && $from && $date ) {
Log("Got all three, push msg");
	   push (@$msgs,"$msgnum|$date|$flags");
           $msgnum = $from = $date = '';
        }
   }


}

sub mbxExists {

my $mbx  = shift;
my $conn = shift;
my $status = 1;

   #  Determine whether a mailbox exists
   sendCommand ($conn, "1 EXAMINE \"$mbx\"");
   while (1) {
        readResponse ($conn);
        last if $response =~ /^1 OK/i;
        if ( $response =~ /^1 NO|^1 BAD/ ) {
           $status = 0;
           last; 
        }
   }

   return $status;
}

sub fetchMsg {

my $msgnum = shift;
my $mbx    = shift;
my $conn   = shift;
my $message;

   Log("   Fetching msg $msgnum...") if $debug;
#  sendCommand ($conn, "1 EXAMINE \"$mbx\"");
#  while (1) {
#       readResponse ($conn);
#       last if ( $response =~ /^1 OK/i );
#  }

   sendCommand( $conn, "1 FETCH $msgnum (rfc822)");
   while (1) {
	readResponse ($conn);
        last if $response =~ /^1 NO|^1 BAD/;
	if ( $response =~ /^1 OK/i ) {
		$size = length($message);
		last;
	} 
	elsif ($response =~ /message number out of range/i) {
		Log ("Error fetching uid $uid: out of range",2);
		$stat=0;
		last;
	}
	elsif ($response =~ /Bogus sequence in FETCH/i) {
		Log ("Error fetching uid $uid: Bogus sequence in FETCH",2);
		$stat=0;
		last;
	}
	elsif ( $response =~ /message could not be processed/i ) {
		Log("Message could not be processed, skipping it ($user,msgnum $msgnum,$destMbx)");
		push(@errors,"Message could not be processed, skipping it ($user,msgnum $msgnum,$destMbx)");
		$stat=0;
		last;
	}
	elsif 
	   ($response =~ /^\*\s+$msgnum\s+FETCH\s+\(.*RFC822\s+\{[0-9]+\}/i) {
		($len) = ($response =~ /^\*\s+$msgnum\s+FETCH\s+\(.*RFC822\s+\{([0-9]+)\}/i);
		$cc = 0;
		$message = "";
		while ( $cc < $len ) {
			$n = 0;
			$n = read ($conn, $segment, $len - $cc);
			if ( $n == 0 ) {
				Log ("unable to read $len bytes");
				return 0;
			}
			$message .= $segment;
			$cc += $n;
		}
	}
   }

   return $message;

}


sub usage {

   print STDOUT "usage:\n";
   print STDOUT " imapcopy -S sourceHost/sourceUser/sourcePassword\n";
   print STDOUT "          -D destHost/destUser/destPassword\n";
   print STDOUT "          -d debug\n";
   print STDOUT "          -I show IMAP protocol exchanges\n";
   print STDOUT "          -L logfile\n";
   print STDOUT "          -m mailbox list (eg \"Inbox, Drafts, Notes\". Default is all mailboxes)\n";
   print STDOUT "          -r clear \\DELETE flag from deleted messages\n";
   print STDOUT "          -p <mailbox> put copied mailboxes under a root mailbox\n";
   print STDOUT "          -M <file> mailbox map file. Maps src mbxs to dst mbxs. ";
   print STDOUT "Each line in the file should be 'src mbx:dst mbx'\n";
   exit;

}

sub processArgs {

   if ( !getopts( "dS:D:L:m:hIp:M:r" ) ) {
      usage();
   }

   ($sourceHost,$sourceUser,$sourcePwd) = split(/\//, $opt_S);
   ($destHost, $destUser, $destPwd)   = split(/\//, $opt_D);
   $mbxList  = $opt_m;
   $logfile  = $opt_L;
   $root_mbx = $opt_p;
   $debug    = 1 if $opt_d;
   $showIMAP = 1 if $opt_I;
   $reset_dflag = $opt_r;
   $mbx_map_fn  = $opt_M;

   usage() if $opt_h;

}

sub selectMbx {

my $mbx = shift;
my $conn = shift;

   #  Some IMAP clients such as Outlook and Netscape) do not automatically list
   #  all mailboxes.  The user must manually subscribe to them.  This routine
   #  does that for the user by marking the mailbox as 'subscribed'.

   sendCommand( $conn, "1 SUBSCRIBE \"$mbx\"");
   while ( 1 ) {
      readResponse( $conn );
      if ( $response =~ /^1 OK/i ) {
         Log("Mailbox $mbx has been subscribed") if $debug;
         last;
      } elsif ( $response =~ /^1 NO|^1 BAD/i ) {
         Log("Unexpected response to subscribe $mbx command: $response");
         last;
      }
   }

   #  Now select the mailbox
   sendCommand( $conn, "1 SELECT \"$mbx\"");
   while ( 1 ) {
      readResponse( $conn );
      if ( $response =~ /^1 OK/i ) {
         last;
      } elsif ( $response =~ /^1 NO|^1 BAD/i ) {
         Log("Unexpected response to SELECT $mbx command: $response");
         last;
      }
   }

}

sub namespace {

my $conn      = shift;
my $prefix    = shift;
my $delimiter = shift;

   #  Query the server with NAMESPACE so we can determine its
   #  mailbox prefix (if any) and hierachy delimiter.

   @response = ();
   sendCommand( $conn, "1 NAMESPACE");
   while ( 1 ) {
      readResponse( $conn );
      if ( $response =~ /^1 OK/i ) {
         last;
      } elsif ( $response =~ /^1 NO|^1 BAD/i ) {
         Log("Unexpected response to NAMESPACE command: $response");
         last;
      }
   }

   foreach $_ ( @response ) {
      if ( /NAMESPACE/i ) {
         my $i = index( $_, '((' );
         my $j = index( $_, '))' );
         my $val = substr($_,$i+2,$j-$i-3);
         ($val) = split(/\)/, $val);
         ($$prefix,$$delimiter) = split( / /, $val );
         $$prefix    =~ s/"//g;
         $$delimiter =~ s/"//g;
         last;
      }
      last if /^1 NO|^1 BAD/;
   }
 
   if ( $debug ) {
      Log("prefix  $$prefix");
      Log("delim   $$delimiter");
   }

}

sub mailboxName {

my $srcmbx    = shift;
my $srcPrefix = shift;
my $srcDelim  = shift;
my $dstPrefix = shift;
my $dstDelim  = shift;
my $dstmbx;
my $substChar = '_';

   #  Adjust the mailbox name if the source and destination server
   #  have different mailbox prefixes or hierarchy delimiters.

   if ( $srcmbx =~ /[$dstDelim]/ ) {
      #  The mailbox name has a character that is used on the destination
      #  as a mailbox hierarchy delimiter.  We have to replace it.
      $srcmbx =~ s^[$dstDelim]^$substChar^g;
   }

   if ( $debug ) {
      Log("src mbx      $srcmbx");
      Log("src prefix   $srcPrefix");
      Log("src delim    $srcDelim");
      Log("dst prefix   $dstPrefix");
      Log("dst delim    $dstDelim");
   }

   $srcmbx =~ s/^$srcPrefix//;
   $srcmbx =~ s/\\$srcDelim/\//g;
 
   #  Change the mailbox name if the user has supplied mapping rules.
   if ( $mbx_map{"$srcmbx"} ) {
      $srcmbx = $mbx_map{"$srcmbx"} 
   }

   if ( ($srcPrefix eq $dstPrefix) and ($srcDelim eq $dstDelim) ) {
      #  No adjustments necessary
      $dstmbx = $srcmbx;
      if ( $root_mbx ) {
         #  Put folders under a 'root' folder on the dst
         $dstmbx =~ s/^$dstPrefix//;
         $dstDelim =~ s/\./\\./g;
         $dstmbx =~ s/^$dstDelim//;
         $dstmbx = $dstPrefix . $root_mbx . $dstDelim . $dstmbx;
         if ( uc($srcmbx) eq 'INBOX' ) {
            #  Special case for the INBOX
            $dstmbx =~ s/INBOX$//i;
            $dstmbx =~ s/$dstDelim$//;
         }
         $dstmbx =~ s/\\//g;
      }
      return $dstmbx;
   }

   $srcmbx =~ s#^$srcPrefix##;
   $dstmbx = $srcmbx;

   if ( $srcDelim ne $dstDelim ) {
       #  Need to substitute the dst's hierarchy delimiter for the src's one
       $srcDelim = '\\' . $srcDelim if $srcDelim eq '.';
       $dstDelim = "\\" . $dstDelim if $dstDelim eq '.';
       $dstmbx =~ s#$srcDelim#$dstDelim#g;
       $dstmbx =~ s/\\//g;
   }
   if ( $srcPrefix ne $dstPrefix ) {
       #  Replace the source prefix with the dest prefix
       $dstmbx =~ s#^$srcPrefix## if $srcPrefix;
       if ( $dstPrefix ) {
          $dstmbx = "$dstPrefix$dstmbx" unless uc($srcmbx) eq 'INBOX';
       }
       $dstDelim = "\\$dstDelim" if $dstDelim eq '.';
       $dstmbx =~ s#^$dstDelim##;
   } 
      
   if ( $root_mbx ) {
      #  Put folders under a 'root' folder on the dst
      $dstDelim =~ s/\./\\./g;
      $dstmbx =~ s/^$dstPrefix//;
      $dstmbx =~ s/^$dstDelim//;
      $dstmbx = $dstPrefix . $root_mbx . $dstDelim . $dstmbx;
      if ( uc($srcmbx) eq 'INBOX' ) {
         #  Special case for the INBOX
         $dstmbx =~ s/INBOX$//i;
         $dstmbx =~ s/$dstDelim$//;
      }
      $dstmbx =~ s/\\//g;
   }

   return $dstmbx;
}

sub flags {

my $flags = shift;
my @newflags;
my $newflags;

   #  Make sure the flags list contains only standard 
   #  IMAP flags.

   return unless $flags;

   $flags =~ s/\\Recent//i;
   foreach $_ ( split(/\s+/, $flags) ) {
      next unless substr($_,0,1) eq '\\';
      push( @newflags, $_ );
   }

   $newflags = join( ' ', @newflags );

   $newflags =~ s/\\Deleted//ig if $opt_r;
   $newflags =~ s/^\s+|\s+$//g;

   return $newflags;
}

sub map_mbx_names {

my $mbx_map = shift;
my $srcDelim = shift;
my $dstDelim = shift;

   #  The -M <file> argument causes imapcopy to read the
   #  contents of a file with mappings between source and
   #  destination mailbox names. This permits the user to
   #  to change the name of a mailbox when copying messages.
   #
   #  The lines in the file should be formatted as:
   #       <source mailbox name>: <destination mailbox name>
   #  For example:
   #       Drafts/2008/Save:  Draft_Messages/2008/Save
   #       Action Items: Inbox
   #
   #  Note that if the names contain non-ASCII characters such
   #  as accents or diacritical marks then the Perl module
   #  Unicode::IMAPUtf7 module must be installed.

   return unless $mbx_map_fn;

   unless ( open(MAP, "<$mbx_map_fn") ) {
      Log("Error opening mbx map file $mbx_map_fn: $!");
      exit;
   }
   $use_utf7 = 0;
   while( <MAP> ) {
      chomp;
      s/^\s+//;
      next if /^#/;
      next unless $_;
      ($srcmbx,$dstmbx) = split(/\s*:\s*/, $_);

      #  Unless the mailbox name is entirely ASCII we'll have to use
      #  the Modified UTF-7 character set.
      $use_utf7 = 1 unless isAscii( $srcmbx );
      $use_utf7 = 1 unless isAscii( $dstmbx );

      $srcmbx =~ s/\//$srcDelim/g;
      $dstmbx =~ s/\//$dstDelim/g;

      $$mbx_map{"$srcmbx"} = $dstmbx;

   }
   close MAP;

   if ( $use_utf7 ) {
      eval 'use Unicode::IMAPUtf7';
      if ( $@ ) {
         Log("At least one mailbox map contains non-ASCII characters.  This means you");
         Log("have to install the Perl Unicode::IMAPUtf7 module in order to map mailbox ");
         Log("names between the source and destination servers.");
         print "At least one mailbox map contains non-ASCII characters.  This means you\n";
         print "have to install the Perl Unicode::IMAPUtf7 module in order to map mailbox\n";
         print "names between the source and destination servers.\n";
         exit;
      }
   }

   my %temp;
   foreach $srcmbx ( keys %$mbx_map ) {
      $dstmbx = $$mbx_map{"$srcmbx"};
      Log("Mapping src:$srcmbx to dst:$dstmbx");
      if ( $use_utf7 ){
         #  Encode the name in Modified UTF-7 charset
         $srcmbx = Unicode::IMAPUtf7::imap_utf7_encode( $srcmbx );
         $dstmbx = Unicode::IMAPUtf7::imap_utf7_encode( $dstmbx );
      }
      $temp{"$srcmbx"} = $dstmbx;
   }
   %$mbx_map = %temp;
   %temp = ();

}

sub isAscii {

my $str = shift;
my $ascii = 1;

   #  Determine whether a string contains non-ASCII characters

   my $test = $str;
   $test=~s/\P{IsASCII}/?/g;
   $ascii = 0 unless $test eq $str;

   return $ascii;

}
