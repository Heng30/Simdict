#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#ifdef HAVE_ICONV
#include <errno.h>
#include <iconv.h>
#endif

#include <X11/Xatom.h>
#include <X11/Xlib.h>
#include <X11/Xmu/Atoms.h>

#include "xclib.h"
#include "xcprint.h"

#define F 0 /* false... */
#define T 1 /* true...  */

#define MIN(a, b) ((a) > (b) ? (b) : (a))

/* Options that get set on the command line */
int sloop = 0;           /* number of loops */
Atom sseln = XA_PRIMARY; /* X selection to work with */
Atom target = XA_STRING;
static int frmnl = F;
static int fsecm = F; /* zero out selection buffer before exiting */

Display *dpy; /* connection to X11 display */

static size_t printSelBuf(FILE *fout, Atom sel_type, unsigned char *sel_buf,
                        size_t sel_len, char *buf, size_t buf_size) {
#ifdef HAVE_ICONV
    Atom html = XInternAtom(dpy, "text/html", True);
#endif

    if (xcverb >= OVERBOSE) { /* print in verbose mode only */
        char *atom_name = XGetAtomName(dpy, sel_type);
        fprintf(stderr, "Type is %s.\n", atom_name);
        XFree(atom_name);
    }

    if (sel_type == XA_INTEGER) {
        /* if the buffer contains integers, print them */
        long *long_buf = (long *)sel_buf;
        size_t long_len = sel_len / sizeof(long);
        while (long_len--)
            fprintf(fout, "%ld\n", *long_buf++);
        return 0;
    }

    if (sel_type == XA_ATOM) {
        /* if the buffer contains atoms, print their names */
        Atom *atom_buf = (Atom *)sel_buf;
        size_t atom_len = sel_len / sizeof(Atom);
        while (atom_len--) {
            char *atom_name = XGetAtomName(dpy, *atom_buf++);
            fprintf(fout, "%s\n", atom_name);
            XFree(atom_name);
        }
        return 0;
    }

#ifdef HAVE_ICONV
    if (html != None && sel_type == html) {
        /* if the buffer contains UCS-2 (UTF-16), convert to
         * UTF-8.  Mozilla-based browsers do this for the
         * text/html target.
         */
        iconv_t cd;
        char *sel_charset = NULL;
        if (sel_buf[0] == 0xFF && sel_buf[1] == 0xFE)
            sel_charset = "UTF-16LE";
        else if (sel_buf[0] == 0xFE && sel_buf[1] == 0xFF)
            sel_charset = "UTF-16BE";

        if (sel_charset != NULL &&
            (cd = iconv_open("UTF-8", sel_charset)) != (iconv_t)-1) {
            char *out_buf_start = malloc(sel_len),
                 *in_buf = (char *)sel_buf + 2, *out_buf = out_buf_start;
            size_t in_bytesleft = sel_len - 2, out_bytesleft = sel_len;

            while (iconv(cd, &in_buf, &in_bytesleft, &out_buf,
                         &out_bytesleft) == ((size_t)-1) &&
                   errno == E2BIG) {
                fwrite(out_buf_start, sizeof(char), sel_len - out_bytesleft,
                       fout);
                out_buf = out_buf_start;
                out_bytesleft = sel_len;
            }
            if (out_buf != out_buf_start)
                fwrite(out_buf_start, sizeof(char), sel_len - out_bytesleft,
                       fout);

            free(out_buf_start);
            iconv_close(cd);
            return 0;
        }
    }
#endif

    size_t len = MIN(sel_len, buf_size);
    memcpy(buf, sel_buf, len);
    return len;
}

static size_t doOut(Window win, char *buf, size_t size) {
    Atom sel_type = None;
    unsigned char *sel_buf;    /* buffer for selection data */
    unsigned long sel_len = 0; /* length of sel_buf */
    XEvent evt;                /* X Event Structures */
    unsigned int context = XCLIB_XCOUT_NONE;
    size_t rdlen = 0;

    if (sseln == XA_STRING) {
        sel_buf = (unsigned char *)XFetchBuffer(dpy, (int *)&sel_len, 0);
    } else {
        while (1) {
            /* only get an event if xcout() is doing something */
            if (context != XCLIB_XCOUT_NONE)
                XNextEvent(dpy, &evt);

            /* fetch the selection, or part of it */
            xcout(dpy, win, evt, sseln, target, &sel_type, &sel_buf, &sel_len,
                  &context);

            if (context == XCLIB_XCOUT_BAD_TARGET) {
                if (target == XA_UTF8_STRING(dpy)) {
                    /* fallback is needed. set XA_STRING to target and restart
                     * the loop. */
                    context = XCLIB_XCOUT_NONE;
                    target = XA_STRING;
                    continue;
                } else {
                    /* no fallback available, exit with failure */
                    if (fsecm) {
                        /* If user requested -sensitive, then prevent further
                         * pastes (even though we failed to paste) */
                        XSetSelectionOwner(dpy, sseln, None, CurrentTime);
                        /* Clear memory buffer */
                        xcmemzero(sel_buf, sel_len);
                    }
                    free(sel_buf);
                    errconvsel(dpy, target, sseln);
                }
            }

            /* only continue if xcout() is doing something */
            if (context == XCLIB_XCOUT_NONE)
                break;
        }
    }

    /* remove the last newline character if necessary */
    if (frmnl && sel_len && sel_buf[sel_len - 1] == '\n') {
        sel_len--;
    }

    if (sel_len) {
        rdlen = printSelBuf(stdout, sel_type, sel_buf, sel_len, buf, size);

        if (fsecm) {
            /* If user requested -sensitive, then prevent further pastes */
            XSetSelectionOwner(dpy, sseln, None, CurrentTime);
            /* Clear memory buffer */
            xcmemzero(sel_buf, sel_len);
        }

        if (sseln == XA_STRING) {
            XFree(sel_buf);
        } else {
            free(sel_buf);
        }
    }

    return rdlen;
}

size_t xclipSel(char *buf, size_t size) {
    char *sdisp = NULL; /* X display to connect to */
    if (!(dpy = XOpenDisplay(sdisp))) {
        errxdisplay(sdisp);
    }

    /* Create a window to trap events */
    Window win =
        XCreateSimpleWindow(dpy, DefaultRootWindow(dpy), 0, 0, 1, 1, 0, 0, 0);

    /* get events about property changes */
    XSelectInput(dpy, win, PropertyChangeMask);

    /* If we get an X error, catch it instead of barfing */
    XSetErrorHandler(xchandler);

    size_t len = doOut(win, buf, size);

    /* Disconnect from the X server */
    XCloseDisplay(dpy);

    return len;
}
