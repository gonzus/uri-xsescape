#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <sys/time.h>
#include "uri.h"
#include "date.h"
#include "cookie.h"

#define TEST_DATE   0x01
#define TEST_URI    0x02
#define TEST_COOKIE 0x04
#define TEST_PERF   0x08
#define TEST_ALL    0xff

static void test_date(void);
static void test_uri(void);
static void test_cookie(void);
static void test_perf(void);
static void check_cookie(Buffer* cookie);
static int strdiff(const char* s1, const char* s2, int insensitive);

int main(int argc, char* argv[])
{
    int mask = argc > 1 ? atoi(argv[1]) : TEST_ALL;

    if (mask & TEST_DATE) {
        test_date();
    }
    if (mask & TEST_URI) {
        test_uri();
    }
    if (mask & TEST_COOKIE) {
        test_cookie();
    }
    if (mask & TEST_PERF) {
        test_perf();
    }

    return 0;
}

static void test_perf(void)
{
    const char* str = "whv=MtW_XszVxqHnN6rHsX0d; expires=Wed, 07 Jan 2026 11:10:40 GMT; domain=.wikihow.com; path=";
    unsigned int iterations = 2e3;
    struct timeval t0, t1;

    gettimeofday(&t0, 0);
    for (int j = 0; j < iterations; ++j) {
        Buffer cookie;
        buffer_wrap(&cookie, str, 0);
        Buffer name;
        Buffer value;
        buffer_init(&name, 0);
        buffer_init(&value, 0);
        int k = 0;
        while (1) {
            cookie_get_pair(&cookie, &name, &value);
            if (name.pos == 0) {
                break;
            }
            ++k;
            buffer_reset(&name);
            buffer_reset(&value);
        }
        assert(k == 4);
    }
    gettimeofday(&t1, 0);
    unsigned long elapsed = ((t1.tv_sec  - t0.tv_sec ) * 1000000 +
                             (t1.tv_usec - t0.tv_usec));
    printf("%u iterations in %lu us, %lf us / iter\n",
           iterations, elapsed,
           (double) elapsed / iterations);

    fprintf(stderr, "=== perf test done! ===\n");
}

static void test_cookie(void)
{
    Buffer cookie;
    buffer_init(&cookie, 0);

    cookie_put_string(&cookie, "Gonzo&Ale", 0, "+LOVE+", 0, 1);
    printf("Cookie: %d - [%s]\n", cookie.pos, cookie.data);

    cookie_put_string(&cookie, "country", 0, "The Netherlands", 0, 0);
    printf("Cookie: %d - [%s]\n", cookie.pos, cookie.data);

    cookie_put_date(&cookie, "expires", 0, "+1h");
    printf("Cookie: %d - [%s]\n", cookie.pos, cookie.data);

    cookie_put_integer(&cookie, "min-age", 0, 10);
    cookie_put_integer(&cookie, "max-age", 0, 13);
    printf("Cookie: %d - [%s]\n", cookie.pos, cookie.data);

    cookie_put_boolean(&cookie, "clever"  , 0, 0);
    cookie_put_boolean(&cookie, "secure"  , 0, 1);
    cookie_put_boolean(&cookie, "HttpOnly", 0, 1);
    printf("Cookie: %d - [%s]\n", cookie.pos, cookie.data);

    check_cookie(&cookie);

    buffer_reset(&cookie);
    buffer_append(&cookie, "foo=bar; path=/", 0);
    buffer_terminate(&cookie);
    check_cookie(&cookie);

    buffer_fini(&cookie);
    fprintf(stderr, "=== cookie test done! ===\n");
}

static void check_cookie(Buffer* cookie)
{
    Buffer name;
    Buffer value;

    buffer_rewind(cookie);
    printf("Cookie string: [%s]\n", cookie->data);

    buffer_init(&name, 0);
    buffer_init(&value, 0);
    while (1) {
        cookie_get_pair(cookie, &name, &value);
        if (name.pos == 0) {
            break;
        }

        printf("Got: [%s] = [%s] (%d)\n", name.data, value.data, cookie->pos);
        buffer_reset(&name);
        buffer_reset(&value);
    }
    buffer_fini(&value);
    buffer_fini(&name);
}

static void test_date(void)
{
    struct Data
    {
        const char* date;
        int valid;
        double offset;
    } data[] = {
        { "gonzo"  , 0,  0             },
        { ""       , 0,  0             },
        { "+"      , 0,  0             },
        { "-"      , 0,  0             },
        { "+ "     , 0,  0             },
        { "+1 "    , 0,  0             },
        { "+ 10m"  , 0,  0             },
        { "+1 0m"  , 0,  0             },
        { "+10 m"  , 0,  0             },
        { "+10m "  , 0,  0             },
        { "now"    , 1,  0             },
        { "NOW"    , 1,  0             }, /* passes current time as a number */
        { "+."     , 1,  0             },
        { "+10s"   , 1,  10            },
        { "-10s"   , 1, -10            },
        { ".5s"    , 1,  0.5           },
        { "+.5s"   , 1,  0.5           },
        { "+0.5s"  , 1,  0.5           },
        { "-.5s"   , 1, -0.5           },
        { "-0.5s"  , 1, -0.5           },
        { "+10m"   , 1,  10*60         },
        { "-10m"   , 1, -10*60         },
        { "+10h"   , 1,  10*60*60      },
        { "-10h"   , 1, -10*60*60      },
        { "+10d"   , 1,  10*86400      },
        { "-10d"   , 1, -10*86400      },
        { "+10M"   , 1,  10*86400*30   },
        { "-10M"   , 1, -10*86400*30   },
        { "+10y"   , 1,  10*86400*365  },
        { "-10y"   , 1, -10*86400*365  },
    };
    int dlen = sizeof(data) / sizeof(data[0]);

    printf("=================\n");

    for (int d = 0; d < dlen; ++d) {
        time_t now = time(0);
        char date[100];

        if (strcmp(data[d].date, "NOW") != 0) {
            strcpy(date, data[d].date);
        } else {
            sprintf(date, "%lu", (unsigned long) now);
        }
        double got = date_compute(date);
        double expected = data[d].valid ? (now + data[d].offset) : -1;
        int ok = expected == got;

        Buffer fmt;
        buffer_init(&fmt, 0);
        if (data[d].valid && ok) {
            date_format(got, &fmt);
        }
        printf("%-3s date [%s] => [%lf] -- [%lf] -- {%s} / %d\n",
               ok ? "OK" : "NOK", date, got, expected, fmt.data, fmt.pos);
        buffer_fini(&fmt);
    }

    fprintf(stderr, "=== date test done! ===\n");
}

static void test_uri(void)
{
    struct Data
    {
        const char* enc;
        const char* dec;
        int insensitive;
    } data[] = {
        { "%21"                  , "!"                  , 0 },
        { "abcdefghijklmno"      , "abcdefghijklmno"    , 0 },  /* this fits into static buffer */
        { "abcdefghijklmnop"     , "abcdefghijklmnop"   , 0 },  /* this causes memory allocation */
        { "Gonzo%20Rules%21"     , "Gonzo Rules!"       , 0 },
        { "~%2fsrc%2fgit_tree"   , "~/src/git_tree"     , 0 },
        { "~%2Fsrc%2fgit_tree"   , "~/src/git_tree"     , 1 },
    };
    int dlen = sizeof(data) / sizeof(data[0]);

    printf("=================\n");
    for (int d = 0; d < dlen; ++d) {
        int elen = strlen(data[d].enc);
        int dlen = strlen(data[d].dec);

        do {
            Buffer benc;
            buffer_wrap(&benc, data[d].enc, elen);

            Buffer bdec;
            buffer_init(&bdec, elen);
            int ok = 0;

            url_decode(&benc, elen, &bdec);
            ok = (dlen == bdec.pos &&
                  strcmp(data[d].dec, bdec.data) == 0);
            printf("%-3s decode [%s] => [%s] -- [%s] (%d/%d)\n",
                   ok ? "OK" : "NOK",
                   data[d].enc, bdec.data, data[d].dec,
                   dlen, bdec.pos);
            buffer_fini(&bdec);
        } while (0);

        do {
            Buffer bdec;
            buffer_wrap(&bdec, data[d].dec, dlen);

            Buffer benc;
            buffer_init(&benc, 3 * dlen);
            int ok = 0;

            url_encode(&bdec, dlen, &benc);
            ok = (elen == benc.pos &&
                  strdiff(data[d].enc, benc.data, data[d].insensitive) == 0);
            printf("%-3s encode [%s] => [%s] -- [%s] (%d/%d)\n",
                   ok ? "OK" : "NOK",
                   data[d].dec, benc.data, data[d].enc,
                   elen, benc.pos);
            buffer_fini(&benc);
        } while (0);
    }

    fprintf(stderr, "=== URI test done! ===\n");
}

static int strdiff(const char* s1, const char* s2, int insensitive)
{
    if (!insensitive) {
        return strcmp(s1, s2);
    }

    return strcasecmp(s1, s2);
}
