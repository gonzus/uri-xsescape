use strict;
use warnings;

use Test::More;
use URI::XSEscape;

my $bytes = pack 'C*', 0x00, 0x0A, 0x1F, 0x2F, 0x3A, 0xAF, 0xFF;
my $escaped = URI::XSEscape::uri_escape($bytes);
my @triplets = ($escaped =~ /%([0-9A-Fa-f]{2})/g);
print $_ for @triplets;
print"\n";

ok(@triplets, 'produces percent-encodings');
for my $hex (@triplets) {
    is($hex, uc($hex), "percent-encoding uses uppercase hex for $hex");
}

done_testing;
