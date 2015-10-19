/* ----------------------------------------------------------------------------
*         ATMEL Microcontroller Software Support 
* ----------------------------------------------------------------------------
* Copyright (c) 2008, Atmel Corporation
*
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions are met:
*
* - Redistributions of source code must retain the above copyright notice,
* this list of conditions and the disclaimer below.
*
* Atmel's name may not be used to endorse or promote products derived from
* this software without specific prior written permission.
*
* DISCLAIMER: THIS SOFTWARE IS PROVIDED BY ATMEL "AS IS" AND ANY EXPRESS OR
* IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT ARE
* DISCLAIMED. IN NO EVENT SHALL ATMEL BE LIABLE FOR ANY DIRECT, INDIRECT,
* INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
* LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
* OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
* LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
* NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
* EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
* ----------------------------------------------------------------------------
*/
#include <pit/pit.h>
#include <adc/ir.h>
#include <utility/led.h>
#include <utility/trace.h>
#include <stdio.h>
#include <nrf24/nrf24.h>
#include <usart/usart.h>
#include <utility/motor.h>
#include <utility/odometry.h>
#include "sam7p.h"
#include "pie.h"

//#define MODE_BASESTATION
#define MODE_PIE

// /////////////////Move TX_HB and TX_Data to Your file ////////////////////////
#define CHANNEL 34 
unsigned char NrfTxNbr = 0;
unsigned int msg;
unsigned int count = 0;

unsigned char reset_wl;


/////////////////////////////////////////////////////////////////////////////////
#ifdef MODE_BASESTATION
 void main(void)
{      
  unsigned int  channel = CHANNEL;
  unsigned char data = 0x07;
  unsigned char t1;
  unsigned char t2;
  unsigned int tmpcount = 0;
  unsigned char wl_data[10];
  unsigned char rs_line[20];
  unsigned char rs_data[10];
  unsigned char tmp_data[50];
  
  // DBGU output configuration
  TRACE_CONFIGURE(DBGU_STANDARD, 115200, BOARD_MCK);
  
  // Configuration PIT (Periodic Interrupt Timer)
  ConfigurePit();
  // Configuration TC (Timer Counter)
  ConfigureTc();
  // Configuration PIO (Paralell In and Out port), Init Interrupt on PIO
  ConfigureButtons();
  ConfigureLeds();
  // Configuration Radio Module nRF24L (PIO and SPI), ConfigureButtons must be executed before
  ConfigureNRF24L();
  ConfigureUSART0();
  ConfigureUSART1();
  
  while(Timer1Tick<2); // wait until NRF24L01 power up
  nrf24l01_power_up(True);
  while(Timer1Tick<4); // wait until NRF24L01 stand by
  Timer1Tick = 0;
  //initialize the 24L01 to the debug configuration as RX and auto-ack disabled
  nrf24l01_initialize_debug(True, nrf_TX_RX_SIZE, False);
  nrf24l01_write_register(0x06, &data, 1);
  nrf24l01_set_as_rx(True);
  Delay_US(130);
  nrf24l01_set_rf_ch(channel);
  nrf24l01_flush_rx();
  Delay_US(300);

  reset_wl = 1;
  while (1) {
    if( nrf_Data > 0 ) {
      nrf_Data = 0;      
      for( t1 = 0; t1<8; t1++ ) {
        wl_data[t1] = nrfRxMessage.Data[t1];     
      }
      LED_Toggle(LED_Green);  
      writeByteSequence_8(wl_data);
    }
    
    if(messageUSART1){
      messageUSART1 = 0;
      pmsgRead(tmp_data);
      while (tmp_data[tmpcount]!='\n'){
        t1 = tmp_data[tmpcount];
        tmpcount++;
        if( t1 >= '0' && t1 <= '9' ) { // If character is 0-9 convert it to num
          if( count < 20) {
            rs_line[count] = t1-'0';
            count++;
          }
        }
        if( t1 >= 'A' && t1 <= 'F' ) { // If character A-F convert to 10-15
          if( count < 20) {
            rs_line[count] = t1-'A'+10;
            count++;
          }
        }        
      } 
      // If character is a line break send packet
      for( count = 0; count <10; count++ ) { // Convert from 16*4 to 8*8
        t1 = (rs_line[count*2])<<4;
        t2 = rs_line[count*2+1];
        rs_data[count] = t1 | t2;
      }
      count = 0;
      tmpcount = 0;     
      if( nrf_Transmission_Done == 1 ) {
        TX_packet_BASE(rs_data); // Send packet.
        LED_Toggle(LED_Yellow);
      }
    }//if msg flag has been raised      
  }//while 
}//main
#endif



#ifdef MODE_PIE
extern char send_clock;
extern double Time_Out_Slow_Down;
extern unsigned char Lost_msg;
extern unsigned char Lost_msg_Slow_Down;
void Global_Variable_Init(void)
{
    odometry(1);
    Check_Battery(1);
    /* Variable Initialize */
    New_Spline_Point_Arrived = 0;
    Lost_msg = 0;
    Lost_msg_Slow_Down = 0;
    send_clock = 0;
    Time_Out_Slow_Down = 1;
}

void main(void)
{  	
  unsigned int  channel = CHANNEL;
  unsigned char data = 0x07;
  
  // DBGU output configuration
  TRACE_CONFIGURE(DBGU_STANDARD, 115200, BOARD_MCK);
  
  // Configuration PIT (Periodic Interrupt Timer)
  ConfigurePit();
  // Configuration TC (Timer Counter)
  ConfigureTc();
  // Configuration PIO (Paralell In and Out port), Init Interrupt on PIO
  ConfigureButtons();
  ConfigureLeds();
  // Configuration Radio Module nRF24L (PIO and SPI), ConfigureButtons must be executed before
  ConfigureNRF24L();
  ConfigureUSART0();
  ConfigureUSART1();
  //initialize proximity sensor
  ir_init();
  Global_Variable_Init();
  
  while(Timer0Tick<2); // wait until NRF24L01 power up
  nrf24l01_power_up(True);
  while(Timer0Tick<4); // wait until NRF24L01 stand by
  Timer0Tick = 0;
  //initialize the 24L01 to the debug configuration as RX and auto-ack disabled
  nrf24l01_initialize_debug(True, nrf_TX_RX_SIZE, False);
  nrf24l01_write_register(0x06, &data, 1);
  nrf24l01_set_as_rx(True);
  Delay_US(130);
  nrf24l01_set_rf_ch(channel);
  nrf24l01_flush_rx();
  Delay_US(300);
  
  while (1) { 
    if(Timer0Tick!=0){
      Timer0Tick = 0;
      Check_Battery(0);
      odometry(0);
      ProxRead_m();
      Send_Coord();
      Delay_US(10000);//give time for the coming message
      feedbackController(goalx, goaly, goaldist);      
    }
    Check_Wireless();
  }//while
}//main
#endif



