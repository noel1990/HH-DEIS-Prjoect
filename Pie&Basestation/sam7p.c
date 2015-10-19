#include <spi/spi.h>
#include <pio/pio.h>
#include <pio/pio_it.h>
#include <tc/tc.h>
#include <pit/pit.h>
#include <irq/irq.h>
#include <nrf24/nrf24.h>
#include <utility/led.h>
#include <usart/usart.h>
#include <stdio.h>
#include <stdlib.h>
#include <pmc/pmc.h>
#include <at91sam7s256/AT91SAM7S256.h>
#include "sam7p.h"
#define MD25_SERIAL_MODE (USART_MODE_ASYNCHRONOUS | AT91C_US_NBSTOP_2_BIT)
#define USART_SERIAL_MODE (AT91C_US_PAR_NONE | 0X3 << 6)
/// Delay for pushbutton debouncing (in milliseconds).
#define DEBOUNCE_TIME       500

volatile unsigned int ticks = 0;
unsigned long Timer0Tick = 0;
unsigned long Timer1Tick = 0;
unsigned long Timer2Tick = 0;
char RxRingBuf[vectorsize];
int USART1HandlerIndex = 0;
int messageUSART1 = 0;
int pmsgIndexUSART1 = 0;

const Pin Pin_NRF24_CE = PIN_NRF24_CE;
const Pin Pin_NRF24_IRQ = PIN_NRF24_IRQ;
const Pin Pin_NRF24_CSN = PIN_NRF24_CSN;
const Pin Pin_NRF24_MOSI = PIN_SPI_MOSI;
const Pin Pin_NRF24_MISO = PIN_SPI_MISO;
const Pin Pin_NRF24_SPCK = PIN_SPI_SPCK;

//------------------------------------------------------------------------------
const Pin pinRX0 = PIN_USART0_RXD;
const Pin pinTX0 = PIN_USART0_TXD;
const Pin pinRX1 = PIN_USART1_RXD;
const Pin pinTX1 = PIN_USART1_TXD;

//-----------------------------------------------------------------
void ConfigureRxTxPin(void){
  PIO_Configure(&pinRX0, 1);
  PIO_Configure(&pinTX0, 1);
}

//--------------------------------------------------------------------

void USART1_IrqHandler(void){
  char datain;
  datain = AT91C_BASE_US1 -> US_RHR;
  RxRingBuf[USART1HandlerIndex++] = datain;
  USART1HandlerIndex %= vectorsize;
  if(datain == '\n'){
    messageUSART1++;
  }
}

void pmsgRead(char *buf){
  int count = 0;
  while(RxRingBuf[pmsgIndexUSART1]!='\n'){
    buf[count] = RxRingBuf[pmsgIndexUSART1];
    count++;
    pmsgIndexUSART1++;
    pmsgIndexUSART1 %= vectorsize;
    count %=vectorsize;
//    int val = atoi("20");
//    val = val++;
  }
    pmsgIndexUSART1++;
}
//
//void USART0_IrqHandler(void){
//  unsigned int datain;
//  datain = AT91C_BASE_US0 -> US_RHR;
//  RxRingBuf[USART0HandlerIndex++] = datain;
//  USART0HandlerIndex %= vectorsize;
//  if(datain == 10){
//    messageUASRT0++;
//  }
//}

//------------------------------------------------------------------------------
void ConfigureUSART0(void){
  PMC_EnablePeripheral(AT91C_ID_US0); // Enable the clock to USART
  ConfigureRxTxPin(); // Configure the pins to be used by USART
  USART_Configure(AT91C_BASE_US0 ,MD25_SERIAL_MODE ,38400 ,BOARD_MCK);
  USART_SetTransmitterEnabled(AT91C_BASE_US0, 1);
  USART_SetReceiverEnabled(AT91C_BASE_US0, 1); 
  //  IRQ_ConfigureIT(AT91C_ID_US0,0,USART0_IrqHandler);
  //  AT91C_BASE_US0->US_IER = AT91C_US_RXRDY;
  //  IRQ_EnableIT(AT91C_ID_US0);
}

void ConfigureUSART1(void){
  PMC_EnablePeripheral(AT91C_ID_US1); // Enable the clock to USART
  PIO_Configure(&pinRX1, 1);
  PIO_Configure(&pinTX1, 1);
  //  ConfigureRxTxPin(); // Configure the pins to be used by USART
  USART_Configure(AT91C_BASE_US1 ,USART_SERIAL_MODE ,115200 ,BOARD_MCK);
  USART_SetTransmitterEnabled(AT91C_BASE_US1, 1);
  USART_SetReceiverEnabled(AT91C_BASE_US1, 1);
  IRQ_ConfigureIT(AT91C_ID_US1,0,USART1_IrqHandler);
  AT91C_BASE_US1->US_IER = AT91C_US_RXRDY;
  IRQ_EnableIT(AT91C_ID_US1);
}

//------------------------------------------------------------------------------
//         Local variables
//------------------------------------------------------------------------------
/// Pushbutton \#1 pin instance.
const Pin pinPB1 = PIN_PUSHBUTTON_1;

/// Pushbutton \#1 pin instance.
const Pin pinPB2 = PIN_PUSHBUTTON_2;

/// Indicates the current state (on or off) for each LED.
volatile unsigned char pLedStates[2] = {1, 1};

void ConfigureNRF24L(void){
  
  AT91S_SPI *pSPI = (AT91S_SPI *)AT91C_BASE_SPI;
  
  PIO_Configure(&Pin_NRF24_CE, 1);
  PIO_Configure(&Pin_NRF24_IRQ, 1);
  PIO_Configure(&Pin_NRF24_CSN, 1);
  PIO_Configure(&Pin_NRF24_MOSI, 1);
  PIO_Configure(&Pin_NRF24_MISO, 1);
  PIO_Configure(&Pin_NRF24_SPCK, 1);
  
  SPI_Configure(pSPI, AT91C_ID_SPI,
                (AT91C_SPI_DLYBCS & (0 << 24)) | // Delay between chip selects (take default: 6 MCK // periods)
                  //		(AT91C_SPI_PCS & (0xE << 16)) | // Peripheral Chip Select (selects SPI_NPCS1 or PA31)
                  (AT91C_SPI_PCS & (0xD << 16)) | // Peripheral Chip Select (selects SPI_NPCS1 or PA31)
                    (AT91C_SPI_LLB & (0 << 7)) | // Local Loopback  (Disabled)
                      (AT91C_SPI_MODFDIS & (1 << 4)) | // Mode Fault Detection (disabled)
                        (AT91C_SPI_PCSDEC & (0 << 2)) | // Chip Select Decode (chip selects connected directly // to peripheral)
                          (AT91C_SPI_PS & (0 << 1)) | // Peripheral Select (fixed)
                            (AT91C_SPI_MSTR & (1 << 0))); // Master/Slave Mode (Master))
  
  SPI_ConfigureNPCS(pSPI, 1, 
                    (AT91C_SPI_DLYBCT & (0x01 << 24)) | // Delay between Consecutive Transfers (32 MCK periods)
                      (AT91C_SPI_DLYBS & (0x01 << 16)) | // Delay Before SPCK (1 MCK period)
                        (AT91C_SPI_SCBR & (0x18 << 8)) | // Serial Clock Baud Rate 2MHz//(baudrate = MCK/24 = 48054841/24 // = 2002285 baud
                          (AT91C_SPI_BITS & (AT91C_SPI_BITS_8)) | // Bits per Transfer (9 bits)
                            (AT91C_SPI_CSAAT & (0x0 << 3)) | // Chip Select Active After Transfer
                              (AT91C_SPI_NCPHA & (0x1 << 1)) | // Clock Phase (data captured on falling edge)
                                (AT91C_SPI_CPOL & (0x0 << 0))); // Clock Polarity (inactive state is logic one)
  SPI_Enable(pSPI);   
  
  nrf24l01_irq_clear_all();
  
  PIO_ConfigureIt(&Pin_NRF24_IRQ, (void (*)(const Pin *)) ISR_NRF24);
  PIO_EnableIt(&Pin_NRF24_IRQ);
}


//------------------------------------------------------------------------------
/// Interrupt handler for TC0 interrupt. Toggles the state of LED\#2.
//------------------------------------------------------------------------------
void TC0_IrqHandler(void)
{
  volatile unsigned int dummy;
  // Clear status bit to acknowledge interrupt
  dummy = AT91C_BASE_TC0->TC_SR;
  ticks ++;
  Timer0Tick ++;
  Timer1Tick ++;
  Timer2Tick ++;
/*  if(ticks == 1){
    ticks = 0;
    LED_Toggle(1);
  }*/
}
// Toggle LED state
//    LED_Toggle(1);
//    printf("2 ");


int convert_ticks(void){
  return ticks/4;
}

void reset_ticks(void){
  ticks = 0;
}

int return_ticks(void){
  return ticks;
}

//------------------------------------------------------------------------------
/// Configure Timer Counter 0 to generate an interrupt every 250ms.
//------------------------------------------------------------------------------
void ConfigureTc(void)
{
  unsigned int div;
  unsigned int tcclks;
  
  // Enable peripheral clock
  AT91C_BASE_PMC->PMC_PCER = 1 << AT91C_ID_TC0;
  
//  // Configure TC for a 4Hz frequency and trigger on RC compare
//  TC_FindMckDivisor(4, BOARD_MCK, &div, &tcclks);
//  TC_Configure(AT91C_BASE_TC0, tcclks | AT91C_TC_CPCTRG);
//  AT91C_BASE_TC0->TC_RC = (BOARD_MCK / div) / 4; // timerFreq / desiredFreq
  
  // Configure TC for a 20Hz frequency and trigger on RC compare
  TC_FindMckDivisor(20, BOARD_MCK, &div, &tcclks);
  TC_Configure(AT91C_BASE_TC0, tcclks | AT91C_TC_CPCTRG);
  AT91C_BASE_TC0->TC_RC = (BOARD_MCK / div) / 20; // timerFreq / desiredFreq
  
  
  // Configure and enable interrupt on RC compare
  IRQ_ConfigureIT(AT91C_ID_TC0, 0, TC0_IrqHandler);
  AT91C_BASE_TC0->TC_IER = AT91C_TC_CPCS;
  IRQ_EnableIT(AT91C_ID_TC0);
  
  // Start the counter if LED is enabled.
  if (pLedStates[1]) {
    
    TC_Start(AT91C_BASE_TC0);
  }
}

//------------------------------------------------------------------------------
/// Interrupt handler for pushbutton\#1. Starts or stops LED\#1.
//------------------------------------------------------------------------------
void ISR_Bp1(void)
{
  static unsigned int lastPress = 0;
  
  // Check if the button has been pressed
  if (!PIO_Get(&pinPB1)) {
    
    // Simple debounce method: limit push frequency to 1/DEBOUNCE_TIME
    // (i.e. at least DEBOUNCE_TIME ms between each push)
    if ((timestamp - lastPress) > DEBOUNCE_TIME) {
      
      lastPress = timestamp;
      
      // Toggle LED state
      pLedStates[0] = !pLedStates[0];
      if (!pLedStates[0]) {
        
        LED_Clear(0);
      }
    }
  }
}

//------------------------------------------------------------------------------
/// Interrupt handler for pushbutton\#2. Starts or stops LED\#2 and TC0.
//------------------------------------------------------------------------------
void ISR_Bp2(void)
{
  static unsigned int lastPress = 0;
  
  // Check if the button has been pressed
  if (!PIO_Get(&pinPB2)) {
    
    // Simple debounce method: limit push frequency to 1/DEBOUNCE_TIME
    // (i.e. at least DEBOUNCE_TIME ms between each push)
    if ((timestamp - lastPress) > DEBOUNCE_TIME) {
      
      lastPress = timestamp;
      
      // Disable LED#2 and TC0 if there were enabled
      if (pLedStates[1]) {
        
        pLedStates[1] = 0;
        LED_Clear(1);
        AT91C_BASE_TC0->TC_CCR = AT91C_TC_CLKDIS;
      }   
      // Enable LED#2 and TC0 if there were disabled
      else {
        
        pLedStates[1] = 1;
        LED_Set(1);
        AT91C_BASE_TC0->TC_CCR = AT91C_TC_CLKEN | AT91C_TC_SWTRG;
      }
    }
  }
}

//------------------------------------------------------------------------------
/// Configures the pushbuttons to generate interrupts when pressed.
//------------------------------------------------------------------------------
void ConfigureButtons(void){
  
  // Configure pios
  PIO_Configure(&pinPB1, 1);
  PIO_Configure(&pinPB2, 1);
  
  // Initialize interrupts
  PIO_InitializeInterrupts(0);
  PIO_ConfigureIt(&pinPB1, (void (*)(const Pin *)) ISR_Bp1);
  PIO_ConfigureIt(&pinPB2, (void (*)(const Pin *)) ISR_Bp2);
  PIO_EnableIt(&pinPB1);
  PIO_EnableIt(&pinPB2);
}

//------------------------------------------------------------------------------
/// Configures LEDs \#1 and \#2 (cleared by default).
//------------------------------------------------------------------------------
void ConfigureLeds(void)
{
  LED_Configure(0);
  LED_Configure(1);
}

unsigned int NextTick0 = 0;
unsigned int NextTick1 = 0;
unsigned int Tick0Period = 0;
unsigned int Tick1Period = 0;

void InitRealTime(unsigned int Timer0,unsigned int Timer1){
  
  Tick0Period = Timer0;
  Tick1Period = Timer1;
  NextTick0 = Timer0+timestamp;
  NextTick1 = Timer1+timestamp;
}

int RealTime0(void)
{
  if(NextTick0 > timestamp)
    return 0;
  else{
    NextTick0 += Tick0Period;
    return 1;
  }
}

int RealTime1(void)
{
  if(NextTick1 > timestamp)
    return 0;
  else{
    NextTick1 += Tick1Period;
    return 1;
  }
}

//------------------------------------------------------------------------------
/// Interrupt handler for NRF24.
//------------------------------------------------------------------------------
void ISR_NRF24(void){
  volatile AT91PS_PIO	pPIO = AT91C_BASE_PIOA;
  unsigned int i;
  unsigned char nrf_Status_Reg;
  nrfMessageType nrfRxTemp;
  
  PIO_DisableIt(&Pin_NRF24_IRQ);
  nrf_Status_Reg = nrf24l01_get_status();
  if((nrf_Status_Reg & nrf24l01_STATUS_RX_DR) == nrf24l01_STATUS_RX_DR){
    nrf24l01_read_rx_payload((unsigned char *)&nrfRxTemp,nrf_TX_RX_SIZE);
    nrf24l01_irq_clear_rx_dr();
    switch(nrfRxTemp.Type){
    case nrf_TYPE_ACK:
      nrf_Ack++;
      nrfRxMessage.Nbr = nrfRxTemp.Nbr;
      break;
    case nrf_TYPE_HB:
      nrf_HeartBeat++;
      break;
    case nrf_TYPE_DATA:
      nrf_Data++;
      nrfRxMessage.Nbr = nrfRxTemp.Nbr;
      for(i=0;i<nrfRxTemp.Size;i++){ // copy data to global variable
        nrfRxMessage.Data[i] = nrfRxTemp.Data[i];
      }
      break;
    case nrf_TYPE_REQUEST:
      nrf_Request++;
      for(i=0;i<nrfRxTemp.Size;i++){ // copy data to global variable
        nrfRxMessage.Data[i] = nrfRxTemp.Data[i];
      }
      break;
    default:
      break;
    }
  }
  if((nrf_Status_Reg & nrf24l01_STATUS_TX_DS) == nrf24l01_STATUS_TX_DS){
    nrf24l01_irq_clear_tx_ds();
    // transmission done! Maybe you need to transmit more?
    nrf24l01_set_as_rx(True);
    nrf_Transmission_Done = 1;
  }
  if((nrf_Status_Reg & nrf24l01_CONFIG_MASK_MAX_RT) == nrf24l01_CONFIG_MASK_MAX_RT){
    nrf24l01_irq_clear_max_rt();
  }
  PIO_EnableIt(&Pin_NRF24_IRQ);
}

