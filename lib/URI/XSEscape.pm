package URI::XSEscape;

use strict;
use warnings;

use XSLoader;
use parent 'Exporter';

our $VERSION = '0.000003';
XSLoader::load( 'URI::XSEscape', $VERSION );

our @EXPORT_OK = qw{
    uri_escape
    uri_escape_utf8
    uri_unescape
};

sub uri_escape_utf8 {
    my ($text, $more) = @_;
    return undef unless defined($text);

    utf8::encode($text);
    return uri_escape($text) unless $more;
    return uri_escape($text, $more);
}

1;

__END__

=pod

=encoding utf8

=head1 NAME

URI::XSEscape - Quick & dirty URI escaping for Perl

=head1 VERSION

Version 0.000003

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
