#! /usr/local/bin/perl

use strict;
use warnings;
use Data::Dumper;

use Net::SNMP;

open HOSTLIST, "< $ARGV[0]";

my @lines = <HOSTLIST>;

my $size = @lines;
print "IP,LOCATION,SOURCE,TIME REMAINING\n";
for(my $n=0;$n<$size;$n++) {
  my @values = split(' ', $lines[$n]);
  if(!defined $values[0]) { exit 0; }
  if(!defined $values[1]) { exit 0; }
  dumpstatus($values[0],$values[1]);
}

exit 0;

sub dumpstatus {

  my ($hostname, $comstring) = @_;

  my $OID_location      = '1.3.6.1.2.1.1.6.0';
  my $OID_outputsource  = '1.3.6.1.2.1.33.1.4.1.0';
  my $OID_timeremaining = '1.3.6.1.2.1.33.1.2.3.0';

  my ($session, $error) = Net::SNMP->session(
    -hostname  => shift || $hostname,
    -community => shift || $comstring,
  );

  if (!defined $session) {
    printf "ERROR: %s.\n", $error;
    exit 1;
  }

  my $location      = $session->get_request(-varbindlist => [ $OID_location      ],);
  my $outputsource  = $session->get_request(-varbindlist => [ $OID_outputsource  ],);
  my $timeremaining = $session->get_request(-varbindlist => [ $OID_timeremaining ],);

  if (!defined $outputsource) {
    print $hostname, ": Unreachable\n";
    $session->close();
    return;
  }


  print $hostname, ",";

  my %location_hash      = %$location;
  my %outputsource_hash  = %$outputsource;
  my %timeremaining_hash = %$timeremaining;

  print $location_hash{$OID_location}, ",";

  if   ($outputsource_hash{$OID_outputsource} == 2) { print "OFF,";   } 
  elsif($outputsource_hash{$OID_outputsource} == 3) { print "MAINS,"; } 
  else                                              { print "BAT,";   }

  print $timeremaining_hash{$OID_timeremaining}, "\n";

  $session->close();

}
