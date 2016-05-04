use strict;
use warnings;
use feature qw{fc};

use Test::More;
use URI::Escape qw{ uri_escape };
use URI::XSEscape qw{ escape_ascii };

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
    foreach my $string (@strings) {
        is(escape_ascii($string), uri_escape($string), "escaping of printable string [$string] works");
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
        is(fc(escape_ascii($string)), fc(uri_escape($string)), "escaping of non-printable string [$show] works");
    }
}
