/* Motor Controller Board Header */

#ifndef _MOTOR_H_
#define _MOTOR_H_

#include <at91sam7s256/AT91SAM7S256.h>


void motor_set_speed(unsigned char Speed_L,unsigned char Speed_R);
void motor_read_encoder(int *Left, int *Right);
int  motor_read_voltage(void);
void motor_init(void);

#endif /* _MOTOR_H_ */

