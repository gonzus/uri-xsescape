use strict;
use warnings;
use feature qw{fc};

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
    );
    my @withs = (
        '&',
    );
    foreach my $string (@strings) {
        foreach my $with (@withs) {
            is(escape_ascii_with($string, $with), uri_escape($string, $with),
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
    );
    foreach my $chars (@strings) {
        foreach my $with (@withs) {
            my $string = join('', map { chr($_) } @$chars);
            my $show = join(':', map { $_ } @$chars);
            is(fc(escape_ascii_with($string, $with)), fc(uri_escape($string, $with)),
               "escaping of non-printable string [$show] with [$with] works");
        }
    }
}
