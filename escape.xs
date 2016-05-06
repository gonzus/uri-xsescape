#define PERL_NO_GET_CONTEXT     /* we want efficiency */
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

/* #include <strings.h> */
#include "buffer.h"
#include "uri.h"

MODULE = URI::XSEscape        PACKAGE = URI::XSEscape
PROTOTYPES: DISABLE

#################################################################

SV*
uri_escape(SV* string, ...)
  PREINIT:
    Buffer answer;
  CODE:
    buffer_init(&answer, 0);
    do {
        if (!string || !SvOK(string) || !SvPOK(string)) {
            croak("uri_escape's mandatory first argument must be a string");
            break;
        }
        if (items > 2) {
            croak("uri_escape called with too many arguments");
            break;
        }

        STRLEN slen = 0;
        const char* sstr = SvPV_const(string, slen);

        Buffer sbuf;
        buffer_wrap(&sbuf, sstr, slen);

        if (items == 1) {
            uri_encode(&sbuf, slen, &answer);
            break;
        }

        SV* escape = ST(1);
        if (!escape || !SvOK(escape) || !SvPOK(escape)) {
            croak("uri_escape's optional second argument must be a string");
            break;
        }

        STRLEN elen = 0;
        const char* estr = SvPV_const(escape, elen);

        Buffer ebuf;
        buffer_wrap(&ebuf, estr, elen);

        uri_encode_matrix(&sbuf, slen, &ebuf, &answer);
    } while (0);
    RETVAL = newSVpv(answer.data, answer.pos);
    buffer_fini(&answer);
  OUTPUT: RETVAL

SV*
uri_unescape(SV* string)
  PREINIT:
    Buffer answer;
  CODE:
    buffer_init(&answer, 0);
    do {
        if (!string || !SvOK(string) || !SvPOK(string)) {
            croak("uri_unescape's mandatory first argument must be a string");
            break;
        }

        STRLEN slen = 0;
        const char* sstr = SvPV_const(string, slen);

        Buffer sbuf;
        buffer_wrap(&sbuf, sstr, slen);

        uri_decode(&sbuf, slen, &answer);
    } while (0);
    RETVAL = newSVpv(answer.data, answer.pos);
    buffer_fini(&answer);
  OUTPUT: RETVAL
