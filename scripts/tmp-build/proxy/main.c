#include <stdio.h>
#include "hardware.h"
#define WDTCTL_               0x0120    /* Watchdog Timer Control */
//#define WDTHOLD             (0x0080)
//#define WDTPW               (0x5A00)

#define METADATA_ADDR 0x140
#define CHAL_ADDR METADATA_ADDR
#define ERMIN_ADDR (CHAL_ADDR+32)
#define ERMAX_ADDR (ERMIN_ADDR+2)
#define ORMIN_ADDR (ERMAX_ADDR+2)
#define ORMAX_ADDR (ORMIN_ADDR+2)
#define EXEC_ADDR (ORMAX_ADDR+2)

// ERMIN/MAX_VAL should correspond to address of dummy_function
#define ERMIN_VAL 0xE0DA
#define ERMAX_VAL 0xE0EE
#define ORMIN_VAL 0x200 
#define ORMAX_VAL 0x210


extern void VRASED (uint8_t *challenge, uint8_t *response, uint8_t operation); 

extern void my_memset(uint8_t* ptr, int len, uint8_t val);

extern void my_memcpy(uint8_t* dst, uint8_t* src, int size);

void dummy_function() {
	uint8_t *out = (uint8_t*)(ORMIN_VAL);
	int i;
	for(i=0; i<32; i++) out[i] = i+i;
}

void success() {
    __asm__ volatile("bis     #240,   r2" "\n\t");  
}

void fail() {
    __asm__ volatile("bis     #240,   r2" "\n\t");  
}


int main() {
    uint8_t response[32];

    uint32_t* wdt = (uint32_t*)(WDTCTL_);
    *wdt = WDTPW | WDTHOLD;

    eint();
    // Fill METADATA buffer
    uint8_t *challenge = (uint8_t*)(CHAL_ADDR);
    my_memset(challenge, 32, 0x00);
    *((uint16_t*)(ERMIN_ADDR)) = ERMIN_VAL;
    *((uint16_t*)(ERMAX_ADDR)) = ERMAX_VAL;
    *((uint16_t*)(ORMIN_ADDR)) = ORMIN_VAL;
    *((uint16_t*)(ORMAX_ADDR)) = ORMAX_VAL;

    // Read METADATA buffer
    uint16_t ERmin = *((uint16_t*)(ERMIN_ADDR));
    uint16_t ERmax = *((uint16_t*)(ERMAX_ADDR));
    uint16_t ORmin = *((uint16_t*)(ORMIN_ADDR));
    uint16_t ORmax = *((uint16_t*)(ORMAX_ADDR));
    uint16_t exec = *((uint16_t*)(EXEC_ADDR));

    // Sanity check
    if(ERmin != ERMIN_VAL || ERmax != ERMAX_VAL || ORmin != ORMIN_VAL || ORmax != ORMAX_VAL || exec == 1) fail();

    // Execute ER
    ((void(*)(void))ERmin)();                      

    // Call VRASED
    my_memcpy(challenge, (uint8_t*)CHAL_ADDR, 32);
    VRASED(challenge, response, 0);                 

    // Write token to P3OUT one by one
    int i;
    for(i=0; i<32; i++) P3OUT = response[i];

    exec = *((uint16_t*)(EXEC_ADDR));
    if(exec != 1) fail();  

    success();
    
    return 0;
}
