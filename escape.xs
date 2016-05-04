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
escape_ascii(SV* string)
  PREINIT:
    Buffer answer;
  CODE:
    buffer_init(&answer, 0);
    if (SvOK(string) && SvPOK(string)) {
        STRLEN slen = 0;
        const char* sstr = SvPV_const(string, slen);

        Buffer sbuf;
        buffer_wrap(&sbuf, sstr, slen);

        uri_encode(&sbuf, slen, &answer);
    }
    RETVAL = newSVpv(answer.data, answer.pos);
    buffer_fini(&answer);
  OUTPUT: RETVAL

SV*
escape_ascii_in(SV* string, SV* escape)
  PREINIT:
    Buffer answer;
  CODE:
    buffer_init(&answer, 0);
    if (SvOK(string) && SvPOK(string) &&
        SvOK(escape) && SvPOK(escape)) {
        STRLEN slen = 0;
        const char* sstr = SvPV_const(string, slen);
        STRLEN elen = 0;
        const char* estr = SvPV_const(escape, elen);

        Buffer sbuf;
        buffer_wrap(&sbuf, sstr, slen);
        Buffer ebuf;
        buffer_wrap(&ebuf, estr, elen);

        uri_encode_in(&sbuf, slen, &ebuf, &answer);
    }
    RETVAL = newSVpv(answer.data, answer.pos);
    buffer_fini(&answer);
  OUTPUT: RETVAL

SV*
escape_ascii_not_in(SV* string, SV* escape)
  PREINIT:
    Buffer answer;
  CODE:
    buffer_init(&answer, 0);
    if (SvOK(string) && SvPOK(string) &&
        SvOK(escape) && SvPOK(escape)) {
        STRLEN slen = 0;
        const char* sstr = SvPV_const(string, slen);
        STRLEN elen = 0;
        const char* estr = SvPV_const(escape, elen);

        Buffer sbuf;
        buffer_wrap(&sbuf, sstr, slen);
        Buffer ebuf;
        buffer_wrap(&ebuf, estr, elen);

        uri_encode_not_in(&sbuf, slen, &ebuf, &answer);
    }
    RETVAL = newSVpv(answer.data, answer.pos);
    buffer_fini(&answer);
  OUTPUT: RETVAL

SV*
unescape(SV* string)
  PREINIT:
    Buffer answer;
  CODE:
    buffer_init(&answer, 0);
    if (SvOK(string) && SvPOK(string)) {
        STRLEN slen = 0;
        const char* sstr = SvPV_const(string, slen);

        Buffer sbuf;
        buffer_wrap(&sbuf, sstr, slen);

        uri_decode(&sbuf, slen, &answer);
    }
    RETVAL = newSVpv(answer.data, answer.pos);
    buffer_fini(&answer);
  OUTPUT: RETVAL
