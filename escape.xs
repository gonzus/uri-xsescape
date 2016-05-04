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
escape_ascii_standard(SV* string)
  PREINIT:
    Buffer escaped;
  CODE:
    buffer_init(&escaped, 0);
    if (SvOK(string) && SvPOK(string)) {
        STRLEN clen = 0;
        const char* csrc = SvPV_const(string, clen);

        Buffer source;
        buffer_wrap(&source, csrc, clen);

        uri_encode(&source, clen, &escaped);
    }
    RETVAL = newSVpv(escaped.data, escaped.pos);
    buffer_fini(&escaped);
  OUTPUT: RETVAL

SV*
unescape_ascii(SV* string)
  PREINIT:
    Buffer unescaped;
  CODE:
    buffer_init(&unescaped, 0);
    if (SvOK(string) && SvPOK(string)) {
        STRLEN clen = 0;
        const char* csrc = SvPV_const(string, clen);

        Buffer source;
        buffer_wrap(&source, csrc, clen);

        uri_decode(&source, clen, &unescaped);
    }
    RETVAL = newSVpv(unescaped.data, unescaped.pos);
    buffer_fini(&unescaped);
  OUTPUT: RETVAL
