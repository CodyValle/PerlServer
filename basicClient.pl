#!/usr/bin/perl

# Enforce good syntax
use strict;
use warnings;

#Socket for connecting to other computers
use IO::Socket::INET;
 
# Auto-flush the  socket, I guess
$| = 1;

# Port and Host definitions
my $host = '107.170.219.218';
my $port = '1208';
 
# Create the socket to connect with
my $socket = new IO::Socket::INET (
 	PeerHost => $host, # Host to connect to
 	PeerPort => $port, # Port to connect to
 	Proto    => 'tcp'  # Protocol type: stream socket
	)
	# In case of socket creation failure
	or die "Could not connect to the server $!.\n";

# Report a connection
print "Connected to the server at $host:$port.\n";

# Send messages while connected
while (1)
{
	# Query what process to do
	print "What would you like to say to the server?\n";
	my $message = <STDIN>; # Read from the terminal
	chomp $message; # Remove the '\n'
	last if $message eq "exit"; # Break if the user says so
	
	# Send some data to the server
	$socket->send("$message\04");
	
	# Get what the server responds
	my $buf = "";
	my $response = "";
	while ($buf ne "\04")  # Loop until the EOF is found (\04)
	{
		$response .= $buf; # Append
		$socket->recv($buf,1);  # Read one byte from the socket and store it in $buf
	}
	
	# Print the response
	print "The server says: $response\n";
}

# Close the connection
print "Closing the connection.\n";
$socket->send("exit\04"); # Tell the server we are done. Don't forget the EOF!
$socket->close();