#!/usr/bin/perl

# Enforce good syntax
use strict;
use warnings;

# Socket for connecting to other computers
use IO::Socket::INET;
 
# Auto-flush the socket
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
	or die "Could not connect to the server. $!.\n";
	
# Report a connection
print "Connected to the server at $host:$port.\n";

# Send messages while connected
while (1)
{
	# Query what process to do
	print "What would you like to do? (put, get, exit)\n";
	my $function = <STDIN>; # Read from the terminal
	chomp $function; # Remove the '\n'
	last if $function eq "exit"; # Break if the user says so
	next if ($function ne "get" and $function ne "put"); # Enforce a proper function
	
	# Tell the server we want to write to it
	$socket->send("$function\04"); # Add an EOF to the end of the response
	
	# Get the filename
	print "What is the file name?\n";
	my $filename = <STDIN>; # Read from the terminal
	chomp $filename; # Remove the '\n'
	
	# Tell the server the filename
	$socket->send("$filename\04"); # Add an EOF to the end of the response
	
	my $buf = "";
	
	# Which function are we performing?
	# Getting a file from the server
	if ($function eq "get")
	{
		# Open the file for writing
		open(my $fh, '>', $filename)
			or die "Could not open file '$filename' $!";
		
		# Get the data from the server
		my $filedata = "";
		while ($buf ne "\04")  # Loop until the EOF is found (\04)
		{
			$filedata .= $buf; # Append
			$socket->recv($buf,1);  # Read one byte from the socket and store it in $buf
		}
		
		# Print to the file
		print $fh $filedata;
	}
	# Sending a file to the server
	elsif ($function eq "put")
	{		
		# Open the file for reading
		open(my $fh, '<:encoding(UTF-8)', $filename)
			or die "Could not open file '$filename' $!";
		
		# Read the file into a buffer
		while (my $line = <$fh>) # Read one line at a time
		{
			$buf .= $line; # Append
		}
		
		# Send the file
		$socket->send("$buf\04"); # Add an EOF to the end of the response
	}
}

# Close the connection
print "Closing the connection.\n";
$socket->send("exit\04"); # Tell the server we are done. Don't forget the EOF!
shutdown($socket, 2); # Flush and shut down the stream
$socket->close(); # Close the connection