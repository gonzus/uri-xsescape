use strict;
use warnings;

use Test::More;
use URI::Escape qw{ uri_escape_utf8 };
use URI::XSEscape qw{ escape_utf8 };

exit main(@ARGV);

sub main {
    test_printable();
    test_non_printable();

    done_testing;
    return 0;
}

sub test_printable {
    my @strings = (
        '',
        'hello',
        'gonzo & ale',
        'I said this: you / them ~ us & me _will_ "do-it" NOW!',
        'http://www.google.co.jp/search?q=小飼弾',
    );
    foreach my $string (@strings) {
        my $escaped = escape_utf8($string);
        printf("GOT escaped [%s]\n", $escaped);
        $escaped =~ s/%([0-9a-zA-Z])([0-9a-zA-Z])/%\u$1\u$2/g;
        is($escaped, uri_escape_utf8($string),
           "escaping of printable string [$string] works");
    }
}

sub test_non_printable {
    my @strings = (
        [ 10, ],
        [ 10, 13, ],
    );
    foreach my $chars (@strings) {
        my $string = join('', map { chr($_) } @$chars);
        my $show = join(':', map { $_ } @$chars);
        my $escaped = escape_utf8($string);
        $escaped =~ s/%([0-9a-zA-Z])([0-9a-zA-Z])/%\u$1\u$2/g;
        is($escaped, uri_escape_utf8($string),
           "escaping of non-printable string [$show] works");
    }
}
