use v6.c;
use Test;
use P5gethostbyname :all;

plan 16;

my $itsanIP = / ^ \d+ \. \d+ \. \d+ \. \d+ $ /;

my $IP = gethostbyname("vhosts.wenzperl.nl", :scalar);
ok inet_ntoa($IP) ~~ $itsanIP;

# vim: ft=perl6 expandtab sw=4
