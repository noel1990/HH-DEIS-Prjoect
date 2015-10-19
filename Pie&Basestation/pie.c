#include "pie.h"
#include "sam7p.h"
#include <math.h>
#include <utility/led.h>
#include <peripherals/adc/ir.h>
#include <utility/odometry.h>
#include <nrf24/nrf24.h>
#include <utility/motor.h>

char send_clock; //set to 1 every 100ms
unsigned int Dist_L;
unsigned int Dist_R;
char Obs_L_Final;
char Obs_R_Final;
int New_Spline_Point_Arrived;
double Time_Out_Slow_Down;
unsigned char Lost_msg;
unsigned char Lost_msg_Slow_Down;
double offsetx, offsety, offseta;
double goalx;
double goaly;
double goaldist;
/*****************************************************
Check battery state function
FirstTime=0 means the first time to check the battery.
FirstTime=1 means not the first time to check.
If the voltage is over 11V, the function will come back.
Else the robot will stop and the green LED will start blinking.
*****************************************************/
void Check_Battery(unsigned char FirstTime)
{
  int Voltage;
  if(FirstTime)
    {
        Voltage = motor_read_voltage();
        while(Voltage<1)
        {
            Voltage = motor_read_voltage();
        }
    }

    Voltage = motor_read_voltage();
    if(Voltage<110)
    {
        motor_set_speed(0,0);
        LED_Toggle(LED_Green);
    }
}

char Check_Error_Rec_Coords(unsigned char* data ){
  char x1, x2, x3;
  int x, y, a, sum;
  //  x1 = (Rec_Index == data[0]);
  x = (int)data[1]*256 + (int)data[2];
  y = (int)data[3]*256 + (int)data[4];
  a = (int)data[5]*256 + (int)data[6];
  sum = (int)data[7];
  x2 = (char)(((x+y+a)%256)==sum);
  x3 = (data[8]==0);
  
  return (x2 && x3);
}

void Check_Wireless(){
  unsigned char i;
  unsigned char tmp_data[9];//receive points info msg
  if(nrf_Data > 0){
    nrf_Data = 0;
    for( i = 0; i<9; i++ ) {
      tmp_data[i] = nrfRxMessage.Data[i];       
    }
    if (Check_Error_Rec_Coords(tmp_data)){
      if(tmp_data[0] == 1){
        offsetx = (((tmp_data[1] << 8)| tmp_data[2])-1000);
        offsety = (((tmp_data[3] << 8)| tmp_data[4])-1000);
        offseta = (((tmp_data[5] << 8)| tmp_data[6])-180)/180.f*PI;
        curx = offsetx;
        cury = offsety;
        curtheta = offseta;          
        curtheta = wrapAngle(curtheta);
      }else if(tmp_data[0] == 0){
        New_Spline_Point_Arrived = 1;
        goalx = (double)(((tmp_data[1] << 8)| tmp_data[2])-1000);
        goaly = (double)(((tmp_data[3] << 8)| tmp_data[4])-1000);
        goaldist = (double)((tmp_data[5] << 8)| tmp_data[6]); 
        //          printf("Rec------------------");
        //          printf("%i ,%i , %i \r\n",(int)goalx,(int)goaly,(int)goaldist);
        //          feedbackController(goalx,goaly,goaldist);
      }
    }
  }//if
}

void Send_Coord(){
  unsigned char Msg[8];
  int xcoord, ycoord, heading, splinev;
  int checksum;
  static char Obs_L_t = 0, Obs_R_t = 0;
  static char t_thre = 3;
  
  if(Obstacle_Left){
    Obs_L_t ++ ;
    if(Obs_L_t > t_thre){
      Obs_L_t = t_thre;
      Obs_L_Final = 1;
    }
    else{
      Obs_L_Final = 0;
    }
  }
  else{
    Obs_L_t = 0;
    Obs_L_Final = 0;
  }
  if(Obstacle_Right){
    Obs_R_t ++ ;
    if(Obs_R_t > t_thre)
    {
      Obs_R_t = t_thre;
      Obs_R_Final = 1;
    }
    else{
      Obs_R_Final = 0;
    }
  }
  else{
    Obs_R_t = 0;
    Obs_R_Final = 0;
  }
  //send coords to PC every 100ms
  if(send_clock == 1){
    send_clock = 0;
    xcoord = (int)(round(curx)+1000);
    ycoord = (int)(round(cury)+1000);
    heading = (int)(round((curtheta*180.f/PI+180)*255/360.f));
    splinev = (int)(round(piecurv));
    
    if(!Obs_L_Final && !Obs_R_Final)      Msg[0] = 0;
    else if(Obs_L_Final && !Obs_R_Final)  Msg[0] = 1;
    else if(!Obs_L_Final && Obs_R_Final)  Msg[0] = 2;
    else                                  Msg[0] = 3;
    //     printf("%i ,%i , %i \r\n",xcoord,ycoord,heading);
    Msg[1] = (unsigned char)( xcoord / 256 % 256);
    Msg[2] = (unsigned char)( xcoord % 256);
    Msg[3] = (unsigned char)( ycoord / 256 % 256);
    Msg[4] = (unsigned char)( ycoord % 256);
    Msg[5] = (unsigned char)( heading );
    Msg[6] = (unsigned char)( splinev );
    
    checksum = ((int)Msg[0]+(int)Msg[1]+(int)Msg[2]+(int)Msg[3]+(int)Msg[4]+(int)Msg[5] + (int)Msg[6]);
    Msg[7] = (unsigned char)(checksum % 256);  
    
    if(nrf_Transmission_Done == 1)
    {
      TX_packet_PIE(Msg);
      LED_Toggle(LED_Yellow);
    }
  }
  else{
    send_clock = 1;
  }
  
}

void ProxRead_m(){
  unsigned int Dist_l_m[19], Dist_r_m[19];
  char i;
  for(i=0; i<19; i++){
    Dist_l_m[i] = ir_getadc(6);
    Dist_r_m[i] = ir_getadc(7);
  }
  Sort(Dist_l_m,19);
  Sort(Dist_r_m,19);
  Dist_L = Dist_l_m[9];
  Dist_R = Dist_r_m[9];
}

void Sort(unsigned int *arr,int i){
  int j;
  unsigned int temp;
  while(i > 0){
    for(j = 0; j < i - 1; j++){
      if(arr[j] > arr[j + 1]){
        temp = arr[j];
        arr[j] = arr[j + 1];
        arr[j + 1] = temp;
      }
    }
    i--;
  }
}

double Min(double x, double y){
  if(x > y) return y;
  else return x;
}

void feedbackController(double goalx, double goaly, double goaldist){
  double dx,dy,eps,rho,gamma,ang_error,kGamma,v,w,ratio;
  double vL,vR,motorL,motorR;
  static double startx,starty,dist_s,dist_t,acc_speed,dec_speed;
  static unsigned char First_Time = 1,Controller_Enable = 0;
  
  Check_Wireless();
  
  if (send_clock){
    if (!New_Spline_Point_Arrived){
      Lost_msg++;
      if (Lost_msg_Slow_Down < 40){
        Lost_msg_Slow_Down++;
      }
    }
    else{
      Lost_msg = 0;
      Lost_msg_Slow_Down = 0;
    }
  }
  if (Lost_msg_Slow_Down < 10){
    Time_Out_Slow_Down = 1;
  }
  else if (Lost_msg_Slow_Down < 20){
    Time_Out_Slow_Down = 0.5;
  }
  else if (Lost_msg_Slow_Down < 30){
    Time_Out_Slow_Down = 0.3;
  }
  else{
    Time_Out_Slow_Down = 0;
  }
  //    if (Lost_msg > 30)
  //    {
  //        if (PIE.Wireless_Channel == 93)
  //        {
  //            PIE.Wireless_Channel = 13;
  //        }
  //        else
  //        {
  //            PIE.Wireless_Channel = 93;
  //        }
  //        changeChannel(PIE.Wireless_Channel);
  //        Lost_msg = 0;
  //    }
  
  if(First_Time){
    if (New_Spline_Point_Arrived == 1){
      startx = curx;
      starty = cury;
      First_Time = 0;
      Controller_Enable = 1;
    }else{
      Controller_Enable = 0;
    }
  }
  
  if(Controller_Enable){
    dx = goalx-curx;
    dy = goaly-cury;
    rho  = sqrt(dx*dx+dy*dy);
    dist_t = goaldist+rho;		
    eps = atan2(dy,dx);
    gamma = wrapAngle(eps-curtheta);		
    ang_error = fabs(gamma);
    if(Obstacle_Left || Obstacle_Right){
      dist_t = 0;
    }
    if(goalx==1600 && goaly==100){// Stop message
      dist_t = 0;
    }
    if(Time_Out_Slow_Down==0){
      dist_t = 0;      
    }
    
    if(dist_t > 5.0){
      dx = curx - startx;
      dy = cury - starty;			
      dist_s = sqrt(dx*dx+dy*dy);			
      acc_speed = 0.5 * dist_s;               //accelerate
      if(fabs(acc_speed)> 250)  acc_speed = copysign(250,acc_speed);//Maximum speed
      dec_speed = 0.5 * dist_t;               //decelerate
      if(dec_speed> 250)  dec_speed = 250;     //Maximum speed
      if(dec_speed< 10 )  dec_speed = 10;      //don't be too slow otherwise it will not move at all
      v = Min(acc_speed,dec_speed);
      if(fabs(v)<8.5) v = 8.5;
      kGamma = 1 + ang_error*10/PI;
      w = kGamma*gamma;
      if(fabs(w)> (PI/6.f)){
        ratio = fabs((PI/6.f)/w);
        w = copysign(PI/6.f,w);
        v=v*ratio;
      }
      if(v > (piecurv+10.0)){
        ratio = (piecurv+10.0)/v;
        w = w*ratio;
        v = piecurv+10.0;
      }
      v = v*Time_Out_Slow_Down;
      w = w*Time_Out_Slow_Down;
      vL = (2.f*v - w*WHEEL_DISTANCE)/2.f;
      vR = (2.f*v + w*WHEEL_DISTANCE)/2.f; 
      motorL = round(dt*(1.f/(MM_PER_TICK))*vL);
      motorR = round(dt*(1.f/(MM_PER_TICK))*vR);
      piecurv = (motorL + motorR)/2.f/dt*MM_PER_TICK;
      if (piecurv < 1.0) piecurv = 1.0;
      motor_set_speed((unsigned char)motorL, (unsigned char)motorR);
    }else{
      motorL = 0;
      motorR = 0;  
      piecurv = (motorL + motorR)/2.f/dt*MM_PER_TICK;
      motor_set_speed((unsigned char)motorL, (unsigned char)motorR);      
      First_Time = 1;
    }
  }
  New_Spline_Point_Arrived = 0;
  printf("%i ,%i , %i \r\n",(int)curx,(int)cury,(int) (180.0f*curtheta/PI));
}
