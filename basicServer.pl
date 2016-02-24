#!/usr/bin/perl

# Enforce good syntax
use strict;
use warnings;

# Socket is for connecting to other computers
use IO::Socket::INET;

# Auto-flush the socket, but I don't know why
$| = 1;

# Port and Host definitions
my $host = '107.170.219.218';
my $port = '1208';

# The socket other computers will connect to
my $socket = new IO::Socket::INET(
	LocalHost => $host,   # Host
	LocalPort => $port,   # Port
	Proto     => 'tcp',   # Stream socket protocol type
	Listen    => 5,       # Maximum number of connections
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

# Wait for a connection
while(1)
{
	# Get what the client wants
	my $buf = "";
	my $request = "";
	while ($buf ne "\04") # Loop until the EOF is found (\04)
	{
		$request .= $buf; # Append
		$cSocket->recv($buf,1); # Read one byte from the socket and store it in $buf
	}
	last if $request eq "exit"; # Close if the client wants to

	# Print out the request
	print "The client says: $request\n";

	# Prepare some data for the client
	my $response = scalar reverse $request; # 'scalar reverse' reverses the string
	print "Responding with: $response\n";
	
	# Send the response
	$cSocket->send("$response\04"); # Add an EOF to the end of the response
}

# Remove the socket from the port
print "Disconnecting the socket.\n";
