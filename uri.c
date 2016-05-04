#include <ctype.h>
#include <stdio.h>
#include <string.h>
#include "uri.h"

/*
 * This file is generated automatically with program "encode".
 */
#include "uri_tables.h"

Buffer* uri_decode(Buffer* src, int length,
                   Buffer* tgt)
{
    if (length < 0) {
        length = src->size;
    }

    /* check and maybe increase space in target */
    buffer_ensure_unused(tgt, length);

    int s = src->pos;
    int t = tgt->pos;
    while (s < (src->pos + length)) {
        if (src->data[s] == '%' &&
            isxdigit(src->data[s+1]) &&
            isxdigit(src->data[s+2])) {
            /* put a byte together from the next two hex digits */
            tgt->data[t++] = MAKE_BYTE(uri_decode_tbl[(int)src->data[s+1]],
                                       uri_decode_tbl[(int)src->data[s+2]]);
            /* we used up 3 characters (%XY) from source */
            s += 3;
        } else {
            tgt->data[t++] = src->data[s++];
        }
    }

    /* null-terminate target and return src as was left */
    src->pos = s;
    tgt->pos = t;
    buffer_terminate(tgt);
    return src;
}

Buffer* uri_encode(Buffer* src, int length,
                   Buffer* tgt)
{
    if (length < 0) {
        length = src->size;
    }

    /* check and maybe increase space in target */
    buffer_ensure_unused(tgt, 3 * length);

    int s = src->pos;
    int t = tgt->pos;
    while (s < (src->pos + length)) {
        unsigned char u = (unsigned char) src->data[s];
        char* v = uri_encode_tbl[(int)u];

        /* if current source character doesn't need to be encoded,
           just copy it to target*/
        if (!v) {
            tgt->data[t++] = src->data[s++];
            continue;
        }

        /* copy encoded character from our table */
        tgt->data[t+0] = '%';
        tgt->data[t+1] = v[0];
        tgt->data[t+2] = v[1];

        /* we used up 3 characters (%XY) in target
         * and 1 character from source */
        t += 3;
        ++s;
    }

    /* null-terminate target and return src as was left */
    src->pos = s;
    tgt->pos = t;
    buffer_terminate(tgt);
    return src;
}

Buffer* uri_encode_in(Buffer* src, int length,
                      Buffer* escape,
                      Buffer* tgt)
{
    if (length < 0) {
        length = src->size;
    }

    /* check and maybe increase space in target */
    buffer_ensure_unused(tgt, 3 * length);

    /*
    * Table has a 0 if that character doesn't need to be encoded;
    * otherwise it has a string with the character encoded in hex digits.
    */
    char uri_encode_tbl[256][3];
    for (int j = 0; j < 256; ++j) {
        uri_encode_tbl[j][0] = 0;
    }
    for (int k = 0; k < escape->size; ++k) {
        int e = escape->data[k];
        sprintf(uri_encode_tbl[e], "%02x", e);
    }

    int s = src->pos;
    int t = tgt->pos;
    while (s < (src->pos + length)) {
        unsigned char u = (unsigned char) src->data[s];
        char* v = uri_encode_tbl[(int)u];

        /* if current source character doesn't need to be encoded,
           just copy it to target*/
        if (!v[0]) {
            tgt->data[t++] = src->data[s++];
            continue;
        }

        /* copy encoded character from our table */
        tgt->data[t+0] = '%';
        tgt->data[t+1] = v[0];
        tgt->data[t+2] = v[1];

        /* we used up 3 characters (%XY) in target
         * and 1 character from source */
        t += 3;
        ++s;
    }

    /* null-terminate target and return src as was left */
    src->pos = s;
    tgt->pos = t;
    buffer_terminate(tgt);
    return src;
}

Buffer* uri_encode_not_in(Buffer* src, int length,
                          Buffer* escape,
                          Buffer* tgt)
{
    if (length < 0) {
        length = src->size;
    }

    /* check and maybe increase space in target */
    buffer_ensure_unused(tgt, 3 * length);

    /*
    * Table has a 0 if that character doesn't need to be encoded;
    * otherwise it has a string with the character encoded in hex digits.
    */
    char uri_encode_tbl[256][3];
    for (int j = 0; j < 256; ++j) {
        int e = j;
        for (int k = 0; k < escape->size; ++k) {
            if (j == escape->data[k]) {
                e = 0;
                break;
            }
        }
        if (!e) {
            uri_encode_tbl[j][0] = 0;
        } else {
            sprintf(uri_encode_tbl[j], "%02x", e);
        }
    }

    int s = src->pos;
    int t = tgt->pos;
    while (s < (src->pos + length)) {
        unsigned char u = (unsigned char) src->data[s];
        char* v = uri_encode_tbl[(int)u];

        /* if current source character doesn't need to be encoded,
           just copy it to target*/
        if (!v[0]) {
            tgt->data[t++] = src->data[s++];
            continue;
        }

        /* copy encoded character from our table */
        tgt->data[t+0] = '%';
        tgt->data[t+1] = v[0];
        tgt->data[t+2] = v[1];

        /* we used up 3 characters (%XY) in target
         * and 1 character from source */
        t += 3;
        ++s;
    }

    /* null-terminate target and return src as was left */
    src->pos = s;
    tgt->pos = t;
    buffer_terminate(tgt);
    return src;
}
