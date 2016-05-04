use strict;
use warnings;

use Test::More;
use URI::Escape qw{ uri_escape };
use URI::XSEscape qw{ escape_ascii_with };

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
        'I said this: you / them will "do it" NOW'
    );
    my @withs = (
        '&',
        '%',
        ': /"',
        # '^a-zA-Z0-9._/:-',
    );
    foreach my $string (@strings) {
        foreach my $with (@withs) {
            my $escaped = escape_ascii_with($string, $with);
            $escaped =~ s/%([0-9a-zA-Z])([0-9a-zA-Z])/%\u$1\u$2/g;
            is($escaped, uri_escape($string, $with),
            "escaping of printable string [$string] with [$with] works");
        }
    }
}

sub test_non_printable {
    my @strings = (
        [ 10, ],
        [ 10, 13, ],
    );
    my @withs = (
        '&',
        '%',
        ': /"',
        # '^a-zA-Z0-9._/:-',
    );
    foreach my $chars (@strings) {
        foreach my $with (@withs) {
            my $string = join('', map { chr($_) } @$chars);
            my $show = join(':', map { $_ } @$chars);
            my $escaped = escape_ascii_with($string, $with);
            $escaped =~ s/%([0-9a-zA-Z])([0-9a-zA-Z])/%\u$1\u$2/g;
            is($escaped, uri_escape($string, $with),
               "escaping of non-printable string [$show] with [$with] works");
        }
    }
}
