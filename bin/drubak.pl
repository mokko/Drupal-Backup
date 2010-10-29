#!/usr/bin/perl

use warnings;
use strict;
use Getopt::Long;
use Pod::Usage;

use lib '/home/Mengel/projects/Drupal-Credentials/lib';
use Drupal::Credentials;
use lib '/home/Mengel/projects/Drupal-Backup/lib';
use Drupal::Backup;
$Drupal::Backup::DebugLevel=1;

#DEBUG
use Data::Dumper;

=head1 NAME

drubak.pl - Backup Drupal with perl

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

General Usage

	drubak.pl [--OPTION(s)] command

More concretely

	drubak.pl --help

	drubak.pl [--install name]
		makes a snapshot (db/files of all installations in sites directory)
		don't follow symlinks in sites_dir on default?
		can be restricted to specific instllation using --install

	drubak.pl [--install name] db
		dumps and compresses one or more dbs using info from settings.php
		can be restricted to specific instllation using --install
			$bak_dir/$install/YYYYMMDDTHHMMSS.sql.tgz

	drubak.pl [--install name] files
		backups from one or more installations to
			$bak_dir/$install/YYYYMMDDTHHMMSS.tgz


=cut

my $config=Drupal::Backup->new();
my $drupal = Drupal::Credentials->new( $config->{drupal_sites} );

{
	my $install;
	GetOptions( 'install:s' => \$install ) or pod2usage(2);
	$config->{install} = $install;

	#print "install:$install\n";
	if ($install) {
		if ( !$drupal->exists($install) ) {
			print "Error: Specified installation not found!";
			exit 4;
		}
	}
}

#
# MAIN
#

if ( $ARGV[0] ) {
	print "which command: $ARGV[0]\n";
	$config->list($drupal)     if $ARGV[0] eq 'list';
	Drupal::Backup::files( $drupal, ) if $ARGV[0] eq 'files';
	$config->db( $drupal, $config->{install} ) if $ARGV[0] eq 'db';
	Drupal::Backup::snapshot();

}

print "TT$config->{drupal_sites}\n";



