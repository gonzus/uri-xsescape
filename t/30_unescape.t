use strict;
use warnings;

use Test::More;
use URI::Escape qw{ uri_unescape };
use URI::XSEscape qw{ unescape_ascii };

exit main(@ARGV);

sub main {
    test_strings();

    done_testing;
    return 0;
}

sub test_strings {
    my @strings = (
        '',
        'hello',
        'gonzo%20%26%20ale',
        '%0a',
        '%0a%0d',
        'I%20said%20this%3a%20you%20%2f%20them%20~%20us%20%26%20me%20_will_%20%22do-it%22%20NOW%21',
    );
    foreach my $string (@strings) {
        my $unescaped = unescape_ascii($string);
        is($unescaped, uri_unescape($string), "unescaping of string [$string] works");
    }
}
