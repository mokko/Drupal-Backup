#!/usr/bin/perl

use strict;
use warnings;
use File::Find;


my $string='mysqli://mimo:horni@localhost/mimo-project';

my $href=extract_db_url ($string);
print $href->{user}."\n";

exit 0;



my $input = "/var/www/vhosts/mimo-project.de/httpdocs/sites";
$input = '/cygdrive/C/cygwin2/home/Mengel/bak/www/mimo';

print "Using as input: $input\n";
print "Looking for settings ...\n";

#using find like this is slow, but my backup jobs have time
find( \&wanted, $input );

print "Tell me your secrets\n";

#foreach (@main::conf) {
#	print "SECRET $_\n";
#}

sub wanted {
	if ( $_ eq "settings.php" ) {
		process_settings($_);
		print "Found settings for\n\t$File::Find::dir\n";
	}
}

sub process_settings {
	my $file = shift;
	open( my $fh, '<', $file ) or die $!;

	#maybe a real parser would specifically exclude php comments
	my $comment = 0;
	while (<$fh>) {

		#weed out comments
		if ( $_ =~ /^\s*\$db_url/ ) {

			#mysqli://mimo:horni@localhost/mimo-project

			#$1 should be 'protocoll'
#			print "\tuser: $2\n";
#			print "\tpassw: $3\n";
#			print "\tmachine:$4\n";
#			print "\tuser:$5\n";
#			print "\tdb:$6\n";

			push @main::conf, $_;
			print "secret: $_\n";
		}
	}
}

sub extract_db_url {
	my $string = shift;
	my $href={};

	print $string."\n";
    #mysqli://mimo:horni@localhost/mimo-project
    $string =~ /(mysqli|mysql):\/\/(\w+):(\w+)@(\w+)\/(\w+)/;

	($1) ? 	$href->{function} = $1 : die "no function found\n";
	($2) ? $href->{username} = $2 : die "no username found\n";
	($3) ? 	$href->{password} = $3 : die "no password found\n";
	($4) ?	$href->{host} = $4 : die "no host found\n";
	($5) ?	$href->{db} = $5 : die "no db found\n";

	print "test".$href->{db}."\n";
	return $href;

}
