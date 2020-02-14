#include <stdio.h>
#include "hardware.h"
int main() {

  __asm__ volatile("mov    &0x0160,   r6" "\n\t");
  __asm__ volatile("mov    #0xe082,   &0x0160" "\n\t");
  __asm__ volatile("mov    &0x0160,   r6" "\n\t");

  __asm__ volatile("mov    &0x0162,   r7" "\n\t");
  __asm__ volatile("mov    #0xffff,   &0x0162" "\n\t");
  __asm__ volatile("mov    &0x0162,   r7" "\n\t");

  __asm__ volatile("mov    &0x0164,   r8" "\n\t");
  __asm__ volatile("mov    #0x2345,   &0x0164" "\n\t");
  __asm__ volatile("mov    &0x0164,   r8" "\n\t");

  __asm__ volatile("mov    &0x0166,   r9" "\n\t");
  __asm__ volatile("mov    #0x6789,   &0x0166" "\n\t");
  __asm__ volatile("mov    &0x0166,   r9" "\n\t");

  __asm__ volatile("mov    &0x0168,   r10" "\n\t");
  __asm__ volatile("mov    #0x1111,   &0x0168" "\n\t");
  __asm__ volatile("mov    &0x0168,   r10" "\n\t");


  // Read
  __asm__ volatile("mov    &0x0160,   r11" "\n\t");
  __asm__ volatile("mov    &0x0162,   r11" "\n\t");
  __asm__ volatile("mov    &0x0164,   r11" "\n\t");
  __asm__ volatile("mov    &0x0166,   r11" "\n\t");
  __asm__ volatile("mov    &0x0168,   r11" "\n\t");


  __asm__ volatile("mov    &0x0160,   r6" "\n\t");
  __asm__ volatile("mov    #0xe0b0,   &0x0160" "\n\t");
  __asm__ volatile("mov    &0x0160,   r6" "\n\t");

  // Read
  __asm__ volatile("mov    &0x0160,   r11" "\n\t");
  __asm__ volatile("mov    &0x0162,   r11" "\n\t");
  __asm__ volatile("mov    &0x0164,   r11" "\n\t");
  __asm__ volatile("mov    &0x0166,   r11" "\n\t");
  __asm__ volatile("mov    &0x0168,   r11" "\n\t");

  // challenge
  __asm__ volatile("mov    #0xaaaa,   &0x0140" "\n\t");
  __asm__ volatile("mov    #0xcccc,   &0x0142" "\n\t");
  __asm__ volatile("mov    #0xeeee,   &0x0144" "\n\t");
  __asm__ volatile("mov    #0x6666,   &0x0146" "\n\t");
  __asm__ volatile("mov    #0x8888,   &0x0148" "\n\t");
  __asm__ volatile("mov    #0x1111,   r6" "\n\t");
  __asm__ volatile("mov    &0x0140,   r6" "\n\t");
  __asm__ volatile("mov    &0x0142,   r6" "\n\t");
  __asm__ volatile("mov    &0x0144,   r6" "\n\t");
  __asm__ volatile("mov    &0x0146,   r6" "\n\t");
  __asm__ volatile("mov    &0x0148,   r6" "\n\t");
  __asm__ volatile("mov    #0xffff,   r6" "\n\t");

  __asm__ volatile("mov    #0x2222,   &0x0150" "\n\t");
  __asm__ volatile("mov    #0x3333,   &0x0152" "\n\t");
  __asm__ volatile("mov    &0x0150,   r6" "\n\t");
  __asm__ volatile("mov    &0x0152,   r6" "\n\t");

  __asm__ volatile("mov    #0x4444,   &0x0150" "\n\t");
  __asm__ volatile("mov    &0x0150,   r6" "\n\t");
  __asm__ volatile("mov    #0x5555,   &0x0152" "\n\t");
  __asm__ volatile("mov    &0x0152,   r6" "\n\t");


  __asm__ volatile("mov    #0xbbbb,   &0x015a" "\n\t");
  __asm__ volatile("mov    &0x015a,   r6" "\n\t");

  __asm__ volatile("br #0xfffe" "\n\t");
  return 0;
}
