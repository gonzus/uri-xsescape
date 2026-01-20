# NAME

URI::XSEscape - Fast XS URI-escaping library, replacing [URI::Escape](https://metacpan.org/pod/URI%3A%3AEscape).

# VERSION

Version 0.002000

# SYNOPSIS

    # load once
    use URI::XSEscape;

    # keep using URI::Escape as you wish

# DESCRIPTION

By loading [URI::XSEscape](https://metacpan.org/pod/URI%3A%3AXSEscape) anywhere, you replace any usage of
[URI::Escape](https://metacpan.org/pod/URI%3A%3AEscape) with a faster C implementation.

You can continue to use [URI::Escape](https://metacpan.org/pod/URI%3A%3AEscape) and any other module that
depends on it just like you did before. It's just faster now.

When you have loaded [URI::XSEscape](https://metacpan.org/pod/URI%3A%3AXSEscape), you can control the
overriding of [URI::Escape](https://metacpan.org/pod/URI%3A%3AEscape)'s methods using the environment
variable `PERL_URI_XSESCAPE`.  Only if it is explicitly set to
zero, the methods in [URI::Escape](https://metacpan.org/pod/URI%3A%3AEscape) will not be overwritten.
This is how the benchmark below is run.

# METHODS/ATTRIBUTES

These match the API described in [URI::Escape](https://metacpan.org/pod/URI%3A%3AEscape).

Please see those modules for documentation on what these methods and
attributes are.

## uri\_escape

## uri\_escape\_utf8

## uri\_unescape

# BENCHMARKS

For the common case, which is calling `uri_escape` with a single
argument, and calling `uri_unescape`, [URI::XSEscape](https://metacpan.org/pod/URI%3A%3AXSEscape) runs between
25 and 34 times faster than [URI::Escape](https://metacpan.org/pod/URI%3A%3AEscape). The other cases are also
faster, but the difference is not that noticeable.

    $ PERL_URI_XSESCAPE=0 perl -Iblib/lib -Iblib/arch tools/bench.pl
    URI::Escape 3.31 / URI::Escape::XS 0.13 / URI::XSEscape 0.000004
    -- uri_escape
                        Rate     URI::Escape URI::Escape::XS   URI::XSEscape
    URI::Escape       50839/s              --            -95%            -97%
    URI::Escape::XS  961538/s           1791%              --            -47%
    URI::XSEscape   1818182/s           3476%             89%              --

    -- uri_escape_in
                        Rate     URI::Escape URI::Escape::XS   URI::XSEscape
    URI::Escape     107991/s              --            -16%            -83%
    URI::Escape::XS 129032/s             19%              --            -80%
    URI::XSEscape   641026/s            494%            397%              --

    -- uri_escape_not_in
                    Rate   URI::XSEscape     URI::Escape URI::Escape::XS
    URI::XSEscape   39968/s              --            -11%            -37%
    URI::Escape     45147/s             13%              --            -29%
    URI::Escape::XS 63939/s             60%             42%              --

    -- uri_escape_utf8
                    Rate   URI::Escape URI::XSEscape
    URI::Escape     40519/s            --          -96%
    URI::XSEscape 1098901/s         2612%            --

    -- uri_unescape
                        Rate     URI::Escape URI::Escape::XS   URI::XSEscape
    URI::Escape       74019/s              --            -93%            -96%
    URI::Escape::XS 1086957/s           1368%              --            -43%
    URI::XSEscape   1923077/s           2498%             77%              --

# AUTHORS

- Gonzalo Diethelm `gonzus AT cpan DOT org`
- Sawyer X `xsawyerx AT cpan DOT org`

# THANKS

- Gisle Aas, for [URI::Escape](https://metacpan.org/pod/URI%3A%3AEscape).
- Brian Fraser, for the early work.
- p5pclub, for the inspiration.
