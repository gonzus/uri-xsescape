package URI::XSEscape;

use strict;
use warnings;

use XSLoader;
use parent 'Exporter';

our $VERSION = '0.000002';
XSLoader::load( 'URI::XSEscape', $VERSION );

our @EXPORT_OK = qw{
    escape_ascii
    escape_ascii_in
    escape_ascii_not_in
    escape_utf8
    unescape
};

sub escape_utf8 {
    my ($text, $more) = @_;
    return undef unless defined($text);

    utf8::encode($text);
    return escape_ascii($text) unless defined($more);

    my $start = substr($more, 0, 1);
    return escape_ascii_in($text, $more) unless $start eq '^';

    $more = substr($more, 1);
    return escape_ascii_not_in($text, $more);
}

1;

__END__

=pod

=encoding utf8

=head1 NAME

URI::XSEscape - Quick & dirty URI escaping for Perl

=head1 VERSION

Version 0.000002

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 AUTHORS

=over 4

=item * Gonzalo Diethelm C<< gonzus AT cpan DOT org >>

=back

=head1 THANKS

=over 4

=item * Brian Fraser

=item * Sawyer X

=item * p5pclub

=back
