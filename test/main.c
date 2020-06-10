#include <stdio.h>
#include "hardware.h"
#define WDTCTL_               0x0120    /* Watchdog Timer Control */
//#define WDTHOLD             (0x0080)
//#define WDTPW               (0x5A00)
#define RST_RESULT_ADDR 0xFE00
#define COPY_ADDR 0x5000
#define ATTEST_DATA_ADDR 0x4000
#define ATTEST_SIZE 0x200

extern void VRASED (uint8_t *challenge, uint8_t *response, uint8_t operation); 

extern void my_memset(uint8_t* ptr, int len, uint8_t val);

extern void my_memcpy(uint8_t* dst, uint8_t* src, int size);

#define ATTEST 0x01
#define EXECUTE 0x02
#define SENSE 0x03

//--------------------------------------------------//
//                 tty_putc function                 //
//            (Send a byte to the UART)             //
//--------------------------------------------------//
int tty_putc (int txdata) {

  // Wait until the TX buffer is not full
  while (UART_STAT & UART_TX_FULL);

  // Write the output character
  UART_TXD = txdata;

  return 0;
}

//--------------------------------------------------//
//        UART RX interrupt service routine         //
//         (receive a byte from the UART)           //
//--------------------------------------------------//
volatile char rxdata;

wakeup interrupt (UART_RX_VECTOR) INT_uart_rx(void) {

  // Read the received data
  rxdata = UART_RXD;

  // Clear the receive pending flag
  UART_STAT = UART_RX_PND;

  // Exit the low power mode
  LPM0_EXIT;
}

void init_uart() {
    UART_BAUD = BAUD;                   // Init UART
    UART_CTL  = UART_EN | UART_IEN_RX;
}

void init_gpio() {
  // P3 is used for outputs and is connected to the LEDs
    P3DIR = 0xFF;
    P3OUT = 97;
	P5DIR = 0xFF;
	P5OUT = 0x00;
  // P1 is used for input p1[0] is connected to btnR (T17 on basys3)
  //DHT_init();
}

void recv_chal(uint8_t chal[32], uint8_t chal_size) {
    uint8_t idx = 0;
    while(1) {
        LPM0;   // wakeup by irq
    
        chal[idx] = rxdata;
        idx++;
		tty_putc(rxdata); // echo back
        if(idx >= chal_size) return;
    }
}

void send_resp(uint8_t resp[32], uint8_t resp_size) {
    uint8_t idx = 0;
    for(idx=0; idx<resp_size; idx++) {
        tty_putc(resp[idx]);
    }
}

int main() {
    uint8_t challenge[32];
    uint8_t response[32];
 
    uint32_t* wdt = (uint32_t*)(WDTCTL_);
    *wdt = WDTPW | WDTHOLD;

    init_uart();
    init_gpio();
    eint();

    uint8_t start = 0xFF;
        
    while (1) {
        P3OUT = start;
    
        LPM0;       //sync, wakeup by irq
	    tty_putc(rxdata); // echo back

        P3OUT = rxdata;    //light up
	}
 
	__asm__ volatile("br #0xffff" "\n\t");
	return 0;
}
