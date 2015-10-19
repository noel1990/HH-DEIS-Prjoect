#ifndef __SAM7P_H
#define __SAM7P_H

#define LED_Yellow 0
#define LED_Green 1

#define vectorsize 50

extern void ConfigureNRF24L(void);
extern void ConfigureTc(void);
extern void ConfigureButtons(void);
extern void ConfigureLeds(void);
extern void ConfigureUSART0(void);
extern void ConfigureUSART1(void);
extern volatile unsigned char pLedStates[2];
extern void InitRealTime(unsigned int Timer0,unsigned int Timer1);
extern int RealTime0(void);
extern int RealTime1(void);

extern int convert_ticks(void);
extern void reset_ticks(void);
extern int return_ticks(void);
extern void pmsgRead(char *buf);
extern unsigned long Timer0Tick;
extern unsigned long Timer1Tick;
extern unsigned long Timer2Tick;
extern int messageUSART1;

#endif
