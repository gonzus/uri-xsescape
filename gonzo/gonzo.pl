package Gonzo;

use strict;
use warnings;

use HTTP::XSCookies qw[bake_cookie crush_cookie];

exit main();

sub main {
    my $c;

    $c = 'cookie.a=foo=bar; cookie.b=1234abcd; no.value.cookie';
    show_cookie('Dancer', $c);
    return 0;

    $c = bake_cookie('name' => 'Gonzo');
    show_cookie('1', $c);

    $c = bake_cookie('Perl&C' => 'They rulez!');
    show_cookie('2', $c);

    $c = bake_cookie('The Netherlands' => {
        value    => 'Europe',
        expires  => '+10m',
        HttpOnly => 1,
    });
    show_cookie('3', $c);

    $c = 'name=Gonzo;path=/tmp/foo;path=/tmp/bar';
    show_cookie('4', $c);

    $c = 'foo=bar; path=/';
    show_cookie('5', $c);

    $c = 'whv=MtW_XszVxqHnN6rHsX0d; expires=Wed, 07 Jan 2026 11:10:40 GMT; domain=.wikihow.com; path=';
    show_cookie('6', $c);

    return 0;
}

sub show_cookie {
    my ($name, $cookie) = @_;

    printf("========\n");
    printf("Cookie string is [%s]\n", $cookie);

    my $h = crush_cookie($cookie);

    printf("--------\n");
    my @keys = sort keys %$h;
    printf("Cookie [%s] has %d keys:\n", $name, scalar @keys);
    for my $key (@keys) {
        printf("[%s] => [%s]\n", $key, $h->{$key});
    }
}
