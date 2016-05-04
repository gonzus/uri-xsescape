use strict;
use warnings;

use Test::More;
use URI::Escape qw{ uri_escape };
use URI::XSEscape qw{ escape_ascii_in };

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
        'gonzo % ale',
        'gonzo &% ale',
        'I said this: you / them ~ us & me _will_ "do-it" NOW!',
        # 'http://www.google.co.jp/search?q=小飼弾',  ## This will fail, it is UTF8
    );
    my @ins = (
        '&',
        '%',
        ': /"',
        # '^a-zA-Z0-9._/:-',
    );
    foreach my $string (@strings) {
        foreach my $in (@ins) {
            my $escaped = escape_ascii_in($string, $in);
            $escaped =~ s/%([0-9a-zA-Z])([0-9a-zA-Z])/%\u$1\u$2/g;
            is($escaped, uri_escape($string, $in),
            "escaping of printable string [$string] in [$in] works");
        }
    }
}

sub test_non_printable {
    my @strings = (
        [ 10, ],
        [ 10, 13, ],
    );
    my @ins = (
        '&',
        '%',
        ': /"',
        # '^a-zA-Z0-9._/:-',
    );
    foreach my $chars (@strings) {
        foreach my $in (@ins) {
            my $string = join('', map { chr($_) } @$chars);
            my $show = join(':', map { $_ } @$chars);
            my $escaped = escape_ascii_in($string, $in);
            $escaped =~ s/%([0-9a-zA-Z])([0-9a-zA-Z])/%\u$1\u$2/g;
            is($escaped, uri_escape($string, $in),
               "escaping of non-printable string [$show] in [$in] works");
        }
    }
}
