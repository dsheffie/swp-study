/*
 * swp_rt.c -- bare-metal runtime for MIPSpro-compiled TSVC/LFK kernels on r9999.
 *
 * Supplies the few libftn/libm entry points the kernels and the MIPSpro-compiled
 * TSVC helpers (helpers.f) reference, plus timing and console reporting:
 *   second_  -> CP0 Count; the last two calls bracket each kernel's timed loop
 *   check_   -> prints name, trip count, cycles of the timed loop, checksum
 *   s_cmp/s_stop -> Fortran CHARACTER compare / STOP
 *   vsinf/vcosf  -> MIPSpro vector sin/cos: vsinf(x, y, n, incx, incy), args by
 *                   value (n32 passes the 5th in $8); range-reduced polynomial
 * Fortran passes everything by reference; CHARACTER args add a hidden length
 * (int, by value) after the explicit arguments.
 */
#include <stdint.h>
#include "sim.h"
#include "swp_rt.h"

static uint32_t g_sec[2];
static int g_nsec = 0;

static inline uint32_t read_count(void) {
  uint32_t v;
  __asm__ volatile("mfc0 %0, $9" : "=r"(v));
  return v;
}

void swp_puts(const char *s) {
  simcon_puts(s);
}

void swp_putu(uint32_t v) {
  simcon_putuint(v);
}

/* small %e-style print: enough to compare checksums across SWP on/off */
void swp_putf(float f) {
  union { float f; uint32_t u; } b;
  double d = f;
  int e = 0;
  b.f = f;
  if(d < 0) {
    simcon_putchar('-');
    d = -d;
  }
  if(d != 0.0) {
    while(d >= 10.0) {
      d /= 10.0;
      e++;
    }
    while(d < 1.0) {
      d *= 10.0;
      e--;
    }
  }
  uint32_t m = (uint32_t)(d * 1000000.0 + 0.5);
  simcon_putuint(m / 1000000);
  simcon_putchar('.');
  for(uint32_t p = 100000; p != 0; p /= 10) {
    simcon_putchar('0' + (m / p) % 10);
  }
  simcon_putchar('e');
  if(e < 0) {
    simcon_putchar('-');
    e = -e;
  }
  simcon_putuint((uint32_t)e);
  simcon_puts(" [");
  simcon_puthex32(b.u);
  simcon_putchar(']');
}

float second_(void) {
  uint32_t c = read_count();
  g_sec[0] = g_sec[1];
  g_sec[1] = c;
  g_nsec++;
  return (float)c;
}

void check_(float *chksum, int *totit, int *n, float *t2, char *name, int namelen) {
  (void)t2;
  for(int i = 0; i < namelen; i++) {
    simcon_putchar(name[i]);
  }
  simcon_puts(" n=");
  simcon_putuint((uint32_t)*n);
  simcon_puts(" iters=");
  simcon_putuint((uint32_t)*totit);
  simcon_puts(" count=");
  simcon_putuint(g_nsec >= 2 ? g_sec[1] - g_sec[0] : 0);
  simcon_puts(" sum=");
  swp_putf(*chksum);
  simcon_putchar('\n');
}

int s_cmp(char *a, char *b, int la, int lb) {
  int n = la > lb ? la : lb;
  for(int i = 0; i < n; i++) {
    char ca = i < la ? a[i] : ' ';
    char cb = i < lb ? b[i] : ' ';
    if(ca != cb) {
      return ca < cb ? -1 : 1;
    }
  }
  return 0;
}

void s_stop(char *s, int len) {
  simcon_puts("STOP ");
  for(int i = 0; i < len; i++) {
    simcon_putchar(s[i]);
  }
  simcon_putchar('\n');
  __asm__ volatile("break");
}

/* sin on [-pi, pi] after reduction; double so no intermediate goes denormal
 * in single precision (r9999 traps denormal operands for OS emulation) */
static double sin_reduced(double x) {
  const double pi = 3.14159265358979323846;
  const double twopi = 2.0 * pi;
  while(x > pi) {
    x -= twopi;
  }
  while(x < -pi) {
    x += twopi;
  }
  double x2 = x * x;
  double term = x;
  double sum = x;
  for(int k = 1; k < 12; k++) {
    term *= -x2 / (double)((2 * k) * (2 * k + 1));
    sum += term;
  }
  return sum;
}

void vsinf(float *x, float *y, int n, int incx, int incy) {
  for(int i = 0; i < n; i++) {
    y[i * incy] = (float)sin_reduced(x[i * incx]);
  }
}

void vcosf(float *x, float *y, int n, int incx, int incy) {
  const double half_pi = 1.57079632679489661923;
  for(int i = 0; i < n; i++) {
    y[i * incy] = (float)sin_reduced(x[i * incx] + half_pi);
  }
}

void swp_exc(void) {
  uint32_t cause, epc, badva, sr;
  __asm__ volatile("mfc0 %0, $13" : "=r"(cause));
  __asm__ volatile("mfc0 %0, $14" : "=r"(epc));
  __asm__ volatile("mfc0 %0, $8" : "=r"(badva));
  __asm__ volatile("mfc0 %0, $12" : "=r"(sr));
  simcon_puts("EXCEPTION cause=");
  simcon_puthex32(cause);
  simcon_puts(" exccode=");
  simcon_putuint((cause >> 2) & 0x1f);
  simcon_puts(" epc=");
  simcon_puthex32(epc);
  simcon_puts(" badva=");
  simcon_puthex32(badva);
  simcon_puts(" sr=");
  simcon_puthex32(sr);
  simcon_putchar('\n');
  __asm__ volatile("break");
}

uint32_t swp_count(void) {
  return read_count();
}
