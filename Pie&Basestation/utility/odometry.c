#include <stdio.h>
#include <string.h>
#include <math.h>
#include "motor.h"
#include "odometry.h"
#include "timer.h"

//#define WHEEL_DISTANCE    20.44
//#define CM_PER_TICK       0.086
//#define dt                0.1
//#define EPS               0.001

double curx;
double cury;
double curtheta;
double piecurv;
int LeftInit;
int RightInit;

double wrapAngle(double angle)
{
  while(angle >  PI) angle-=2*PI;
  while(angle < -PI) angle+=2*PI;
  return angle;
}

void odometry(char fristTime){
  int EL_cur,ER_cur,dEL,dER;
  double L,dx,dy,dtheta;
  static int LastEL,LastER;
  if(fristTime){
    motor_read_encoder( &EL_cur , &ER_cur);
    LastEL = EL_cur;
    LastER = ER_cur;
  }else{
    motor_read_encoder( &EL_cur , &ER_cur);
    dEL = EL_cur - LastEL;
    dER = ER_cur - LastER;
    LastEL = EL_cur;
    LastER = ER_cur;		
    /*Local frame*/
    dtheta = ((double)dER-(double)dEL)*MM_PER_TICK/WHEEL_DISTANCE;
    L  = ((double)dEL + (double)dER)/2.f*MM_PER_TICK;
    if(dtheta != 0)  L = L*2.f*sin(dtheta/2.f)/dtheta;
    dx = L*cos(dtheta/2.f);
    dy = L*sin(dtheta/2.f);
    /*World Frame*/ 
    curx = curx + dx*cos(curtheta) - dy*sin(curtheta);
    cury = cury + dy*cos(curtheta) + dx*sin(curtheta);
    curtheta = wrapAngle(curtheta + dtheta);
  }
}

//void PFC(double goalx, double goaly, double goaltheta){
//  static int LastEL;
//  static int LastER;
//  static int firstTime = 1;
// 
//  if(firstTime){
//    firstTime = 0;
//    LastEL = LeftInit;
//    LastER = RightInit;
//  }
//  LED_Toggle(0);
//  double  dx = goalx - curx;
//  double  dy = goaly - cury;
//  double  dtheta = goaltheta - curtheta;
//  double  eps = atan2(dy , dx);
//  double  rho = sqrt(dx*dx + dy*dy);
//  double  gamma = eps - curtheta;
//  if(gamma > PI) gamma -= 2*PI;
//  if(gamma < -PI) gamma += 2*PI;  
//  double  delta = goaltheta - gamma - curtheta;
//  if(delta > PI) delta -= 2*PI;
//  if(delta < -PI) delta += 2*PI;  
//  //kGamma = 1+fabs(gamma)*10/PI
//  //double kRho = 0.5 , kGamma = 0.65, kDelta = -0.25;
//  double kRho = 0.5 , kGamma = 3, kDelta = -1;
//  double v = kRho*rho;
//  double w = kGamma*gamma + kDelta*delta;
//  
//  /* speed limits: vmax=25cm/s wmax=PI/6 */  
//  if(fabs(v)> 25)    v = copysign(25,v);
//  if(fabs(w)> PI/5.f ) {
//    double ratio= fabs((PI/5.f)/w);
//    w = copysign(PI/5.f,w);
//    v=v*ratio;
//  }
//  
//  /* acceleration limit */
//  const double alimit =25/(1000/50);
//  static double prev = 0;
//  if(fabs(v - prev) > alimit) {
//    v = prev + copysign(alimit, (v - prev));
//  }
//  prev = v;
//  
//  double vL = (2.f*v - w*WHEEL_DISTANCE)/2.f;
//  double vR = (2.f*v + w*WHEEL_DISTANCE)/2.f;
//  
//  double motorL = dt*(1.f/(CM_PER_TICK))*vL;
//  double motorR = dt*(1.f/(CM_PER_TICK))*vR;
//  
//  motor_set_speed((unsigned char)motorL, (unsigned char)motorR);
////  motor_set_speed(1, -1);
//  int dEL;
//  int dER;
//  int EL_cur;
//  int ER_cur;
//  motor_read_encoder( &EL_cur , &ER_cur);
//  dEL = EL_cur - LastEL;
//  dER = ER_cur - LastER;
//  LastEL = EL_cur;
//  LastER = ER_cur;
//  
//  vL = (dEL)*CM_PER_TICK/dt;
//  vR = (dER)*CM_PER_TICK/dt;
//  v = (vL+vR)/2.f;
//  w = (vR-vL)/WHEEL_DISTANCE;
//  dtheta = w*dt;
//  
//  if(fabs(w) < EPS){
//    if(w >= 0)
//      w = EPS;
//    else
//      w = -EPS;
//  }
//  double S = v/w;
//  double L = v*dt;
//  /* Local Frame */
//  if(fabs(w) > EPS){
//    /* curve */
//    dx = S*sin(dtheta);
//    dy = S*(1-cos(dtheta));
//  }else{
//    /* straight */
//    dx = L*cos(dtheta/2.f);
//    dy = L*sin(dtheta/2.f);
//  }
//  
//  /* Position updating
//  * World Frame
//  */  
//  curx = curx + dx*cos(curtheta) - dy*sin(curtheta);
//  cury = cury + dy*cos(curtheta) + dx*sin(curtheta);
//  curtheta = curtheta + dtheta;
//  // printf("%i ,%i , %i \r\n",(int)curx,(int)cury,(int) (180.0f*curtheta/PI));
//  if(curtheta > PI) curtheta -= 2*PI;
//  if(curtheta < -PI) curtheta += 2*PI;  
//}
