#include <ctype.h>
#include <stdio.h>
#include <string.h>
#include "uri.h"

/*
 * This file is generated automatically with program "encode".
 */
#include "uri_tables.h"

#define SET_ENCODE_VALUE(var, pos, flag) \
    do { \
        if (flag) { \
            sprintf(var[pos], "%02x", pos); \
        } else { \
            var[pos][0] = 0; \
        } \
    } while (0)

static void fill_matrix(const Buffer* escape, char matrix[256][3]);

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

Buffer* uri_encode_matrix(Buffer* src, int length,
                          Buffer* escape,
                          Buffer* tgt)
{
    if (length < 0) {
        length = src->size;
    }

    /* check and maybe increase space in target */
    buffer_ensure_unused(tgt, 3 * length);

    char uri_encode_tbl[256][3];
    fill_matrix(escape, uri_encode_tbl);

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

static void fill_matrix(const Buffer* escape, char matrix[256][3])
{
    /*
    * Table has a 0 if that character doesn't need to be encoded;
    * otherwise it has a string with the character encoded in hex digits.
    */
    int flag = 0;
    int beg = escape->pos;
    if (escape->data[beg] == '^') {
        flag = 1;
        ++beg;
    }
    /* printf("Using flag %d, beg %d, size %d\n", flag, beg, escape->size); */

    /* Set default values and flip flag */
    for (int j = 0; j < 256; ++j) {
        SET_ENCODE_VALUE(matrix, j, flag);
    }
    flag = !flag;

    for (int pos = beg; pos < escape->size; ++pos) {
        if (escape->data[pos] != '-' ||
            (pos == beg || pos == (escape->size - 1))) {
            /* printf("Found char %c\n", escape->data[pos]); */
            int p = escape->data[pos];
            SET_ENCODE_VALUE(matrix, p, flag);
            continue;
        }
        /* printf("Found range %c %c\n", escape->data[pos-1] + 1, escape->data[pos+1]); */
        for (int p = escape->data[pos-1] + 1; p <= escape->data[pos+1]; ++p) {
            SET_ENCODE_VALUE(matrix, p, flag);
        }
        ++pos; /* need to skip over the '-' and the next character */
    }
}
