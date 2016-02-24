#!/usr/bin/perl

# Enforce good syntax
use strict;
use warnings;

# Socket is for connecting to other computers
use IO::Socket::INET;

# Auto-flush the socket, but I don't know why
$| = 1;

# Close the server with Ctrl-C
$SIG{INT} = \&onQuit;

# Port and Host definitions
my $host = '107.170.219.218';
my $port = '1208';

# The socket other computers will connect to
my $socket = new IO::Socket::INET(
	LocalHost => $host,   # Host
	LocalPort => $port,   # Port
	Proto     => 'tcp',   # Stream socket protocol type
	Listen    => 1,      # Maximum number of connections
	Reuse     => 1        # Reuse, just in case the port is already in use
	)
	# In case of socket creation failure
	or die "Failure creating Socket: $!\n";

# Socket up and running
print "Listening on $host:$port.\n";

# Client socket declaration. Waits until someone has connected.
my $cSocket = $socket->accept();

# Got a connection, learn about it
print "Connected to ",$cSocket->peerhost(),":",$cSocket->peerport(),".\n";

# Loop until the client wants to disconnect
while(1)
{	
	# Get what the client wants
	my $buf = "";
	my $function = "";
	while ($buf ne "\04") # Loop until the EOF is found (\04)
	{
		$function .= $buf; # Append
		$cSocket->recv($buf,1); # Read one byte from the socket and store it in $buf
	}
	last if $function eq "exit"; # Close if the client wants to
	
	# Get the name of the file to read/write
	$buf = "";
	my $filename = "";
	while ($buf ne "\04") # Loop until the EOF is found (\04)
	{
		$filename .= $buf; # Append
		$cSocket->recv($buf,1);  # Read one byte from the socket and store it in $buf
	}
	
	# If we are sending to the client
	if ($function eq "get")
	{
		# Report what we are doing
		print "Reading $filename\n";
		
		# Open the file for writing
		open(my $fh, '<:encoding(UTF-8)', $filename)
			or die "Could not open file '$filename' $!";
		
		# Read the file into a buffer
		$buf = "";
		while (my $line = <$fh>) # Read one line at a time
		{
			$buf .= $line; # Append
		}
		
		# Send the file
		$cSocket->send("$buf\04"); # Add an EOF to the end of the response
	}
	# If the client is sending to us
	elsif ($function eq "put")
	{
		# Report what we are doing
		print "Writing $filename\n";
		
		# Open the file for writing
		open(my $fh, '>', $filename)
			or die "Could not open file '$filename' $!";
		
		# Get the data from the client
		$buf = "";
		my $filedata = "";
		while ($buf ne "\04")  # Loop until the EOF is found (\04)
		{
			$filedata .= $buf; # Append
			$cSocket->recv($buf,1);  # Read one byte from the socket and store it in $buf
		}
	
		# Print the data to the file
		print $fh "$filedata";
	}
}

# For clean exit
onQuit();

# Cleans up the program. Runs when Ctrl-c is pressed
sub onQuit
{
	# Remove the socket from the port
	print "Disconnecting the socket.\n";
	$socket->close();
	exit(0);
}