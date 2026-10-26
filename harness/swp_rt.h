#ifndef __SWP_RT_H__
#define __SWP_RT_H__

#include <stdint.h>

void swp_puts(const char *s);
void swp_putu(uint32_t v);
void swp_putf(float f);
uint32_t swp_count(void);

#endif
