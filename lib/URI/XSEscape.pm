package URI::XSEscape;

use strict;
use warnings;

use XSLoader;
use parent 'Exporter';

our $VERSION = '0.000001';
XSLoader::load( 'URI::XSEscape', $VERSION );

our @EXPORT_OK = qw{
    escape_ascii_standard
    escape_ascii_explicit
};

1;

__END__

=pod

=encoding utf8

=head1 NAME

URI::XSEscape - Quick & dirty URI escaping for Perl

=head1 VERSION

Version 0.000001

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
