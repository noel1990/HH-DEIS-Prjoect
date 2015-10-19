/* Motor Controller Board */

#include <stdio.h>
#include <usart/usart.h>
#include "odometry.h"

void motor_set_speed(unsigned char Speed_L,unsigned char Speed_R)
{
  USART_PutChar(AT91C_BASE_US0,0);
  USART_PutChar(AT91C_BASE_US0,0x34);
  //       USART_PutChar(AT91C_BASE_US0,1);//MOTOR MODE 1 -128 FULL REVERSE 0 STOP 128 FULL FORWARD
  USART_PutChar(AT91C_BASE_US0,0);//MOTOR MODE 0 0-FULL REVERSE 128 STOP 255 FULL FORWARD
  USART_PutChar(AT91C_BASE_US0,0);
  USART_PutChar(AT91C_BASE_US0,0x31);
  USART_PutChar(AT91C_BASE_US0,Speed_L+128);
  USART_PutChar(AT91C_BASE_US0,0);
  USART_PutChar(AT91C_BASE_US0,0x32);
  USART_PutChar(AT91C_BASE_US0,Speed_R+128);
}

void motor_read_encoder(int *Left, int *Right)
{
  unsigned char Vec[8];
  int ReceivedCh = 0;
  int ErrorCnt = 0;
  
  USART_PutChar(AT91C_BASE_US0,0);
  USART_PutChar(AT91C_BASE_US0,0x25);
  while(ReceivedCh < 8 && ErrorCnt < 100000){
    if(USART_IsDataAvailable(AT91C_BASE_US0)){
      Vec[ReceivedCh]=USART_GetChar(AT91C_BASE_US0);
      ReceivedCh++;
    }
    ErrorCnt++;
  }
  if(ErrorCnt >= 100000){
    *Left = 0;
    *Right = 0;
  }
  else{
    *Left = (Vec[0] << 24) | (Vec[1] << 16) | (Vec[2] << 8) | Vec[3];
    *Right = (Vec[4] << 24) | (Vec[5] << 16) | (Vec[6] << 8) | Vec[7];
  }
}

int  motor_read_voltage(void)
{
  unsigned char Ch = 0;
  int ReceivedCh = 0;
  int ErrorCnt = 0;
  
  USART_PutChar(AT91C_BASE_US0,0);
  USART_PutChar(AT91C_BASE_US0,0x26);
  while(ReceivedCh < 1 && ErrorCnt < 100000){
    if(USART_IsDataAvailable(AT91C_BASE_US0)){
      Ch=USART_GetChar(AT91C_BASE_US0);
      ReceivedCh++;
    }
    ErrorCnt++;
  }
  if(ErrorCnt >= 100000){
    return -1;
  }
  else
    return Ch;
}

void motor_init(void)
{
  /* wait for MD25 startup and check voltage */
  printf("\x1B[2J\x1B[HPIE: Checking Voltage... "); fflush(0);
  while (1) {
    int voltage = motor_read_voltage();
    if (voltage == -1)
      continue;
    
    if (voltage > 110) {
      printf("ok (%i). Ready.\n", voltage);
      break;
    } else {
      printf("low. Halting.\n");
      //			ErrorHandle(5);
    }
  }
}

