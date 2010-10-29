#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Drupal::Backup2' ) || print "Bail out!
";
}

diag( "Testing Drupal::Backup2 $Drupal::Backup2::VERSION, Perl $], $^X" );
