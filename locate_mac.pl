use JSON;
use Data::Dumper;

my $mactable_filename = $ARGV[0];
my $iftable_filename  = $ARGV[1];
my $search_macaddress = $ARGV[2];

# Load in mactables and iftables, decode JSON
open MACTABLE, $mactable_filename or die "Couldn't open file: $!"; 
$mactable_string = join("", <MACTABLE>); 
close MACTABLE;

open IFTABLE, $iftable_filename or die "Couldn't open file: $!"; 
$iftable_string = join("", <IFTABLE>); 
close IFTABLE;

my $mactable;
my $iftable;

$mactable = decode_json $mactable_string;
$iftable  = decode_json $iftable_string;

#print Dumper(%{$mactable});
#print Dumper(%{$iftable});

my $decmac = hexmac2dec($search_macaddress);

$decmac = "1.3.6.1.2.1.17.7.1.2.2.1.2.1" . $decmac;

my %mact = %{$mactable};

#print Dumper(%mact);
my $port_id = $mact{$decmac};


my $portoid = "1.3.6.1.2.1.2.2.1.2." . $port_id;
my %ift = %{$iftable};

if($port_id == "") { exit(0); }
#print "Decimal Mac OID : " . $decmac . "\n";
#print "search mac      : ", $search_macaddress, "\n";
#print "Port ID         : " . $port_id . "\n";

my @devicewords = split(/_/,$mactable_filename);
my $device;
my $devicewords_size = @devicewords;
for(my $n=0;$n<($devicewords_size-1);$n++) {
  $device .= $devicewords[$n];
}

print "Found: " . $device . ", " . $ift{$portoid};

my %imact = inverthash(%mact);

#print "MAC Count on port: ", $imact{$port_id}, "\n";
if($imact{$port_id} >  1) { print " (UPLINK)"; }
if($imact{$port_id} == 1) { print " (HOSTPORT)"; }
print "\n";

sub inverthash {
  my (%inputhash) = @_;

  my %outputhash;
  for $key (keys % inputhash) {
    my $value = $inputhash{$key};
    $outputhash{$value}++;
  }

  return %outputhash;
}

sub hexmac2dec {

  my ($hexmac, @args) = @_;


  @words=split(/:/,$hexmac);
  for $word(@words)
  {
    $decmac .= "." . hex($word);
  }

  return $decmac;
}

