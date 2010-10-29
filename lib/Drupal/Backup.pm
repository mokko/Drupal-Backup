package Drupal::Backup;

use warnings;
use strict;
use Carp qw/croak carp/;

use YAML::Any qw(LoadFile);

=head1 NAME

Drupal::Backup - The great new Drupal::Backup!

=head1 VERSION

Version 0.01

=cut

our $VERSION    = '0.01';
our $DebugLevel = 0;        # 0 off
                            # 1 warnings
                            # 2 debug

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Drupal::Backup2;

    my $foo = Drupal::Backup2->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=cut

sub warning;

sub new {
	my $class  = shift;
	my $config = {};

	if ( $DebugLevel gt 0 ) {
		print "DebugLevel set to level $DebugLevel\n";
	}

	my $config_file = "$ENV{HOME}/.drubak.yml";
	if ( -e $config_file ) {
		$config = LoadFile($config_file);
	} else {
		print "Error: Config file missing ($config_file)!";
		exit 1;
	}

	#test config

	#test if variable exists alphabetically
	foreach (qw/bak_dir drupal_sites/) {
		if ( !$config->{$_} ) {
			print "Error: Config not complete ($_)";
			exit 2;
		}
	}

	#test if file item exists
	if ( !-e $config->{drupal_sites} ) {
		print "Error: File item $config->{drupal_sites} does not exist "
		  . "($config->{drupal_sites})";
		exit 3;
	}
	if ( !-d $config->{bak_dir} ) {
		warning "$config->{bak_dir} does not exist. Will try to make it\n";
		mkdir $config->{bak_dir} or croak "Couldn't make directory!";
	}
	bless( $config, $class );
	return $config;
}

sub warning {
	if ( $DebugLevel > 0 ) {
		my $msg = shift;
		print "Warning: $msg";
	}
}

=head2 _drush_sql_dump

=cut

sub _drush_sql_dump {
	my $self   = shift;
	my $root   = shift;
	my $target = shift;

	if ( !$root or !$target ) {
		croak "Error: Need target";
	}

	my $cmd = '';

	if ( $self->{drush} ) {
		$cmd .= $self->{drush} . ' ';
	} else {
		$cmd .= 'drush ';
	}

	$cmd .= "--root='$root' ";
	$cmd .= "--result-file='$target' ";
	$cmd .= 'sql-dump';
	print $cmd. "\n";

}

=head2 bak_date
=cut

sub bak_date {
	my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) =
	  localtime(time);

	$year += 1900;
	$mon = sprintf( "%02d", $mon + 1 );
	return "$year$mon$mday" . 'T' . "$hour$min$sec";

}

sub list {
	my $self   = shift;
	my $drupal = shift;
	foreach ( $drupal->list ) {
		print "$_\n";
	}
	exit;
}

sub files {
	exit;
}

sub db {
	my $self     = shift;
	my $drupal   = shift;
	my $install  = shift;
	my $bak_date = bak_date();

	my @list;
	if ($install) {
		push @list, $install;
	} else {
		@list = $drupal->list;
	}

	foreach my $install (@list) {
		my $result_file = $self->{bak_dir};
		$result_file .= "/$install";
		$result_file .= "/$bak_date.sql";
		$self->_drush_sql_dump( $drupal->get_install_dir($install),
			$result_file );

	}

	exit;

}

sub snapshot {
	exit;
}

=head1 AUTHOR

Maurice Mengel, C<< <mauricemengel at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-drupal-backup2 at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Drupal-Backup2>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Drupal::Backup2


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Drupal-Backup2>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Drupal-Backup2>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Drupal-Backup2>

=item * Search CPAN

L<http://search.cpan.org/dist/Drupal-Backup2/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2010 Maurice Mengel.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1;    # End of Drupal::Backup2
