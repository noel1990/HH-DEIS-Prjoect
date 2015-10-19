#ifndef _PIE_H_
#define _PIE_H_


extern double curx;
extern double cury;
extern double curtheta;
extern double piecurv;
extern char send_clock;
extern double offsetx, offsety, offseta;
extern double goalx;
extern double goaly;
extern double goaldist;
extern unsigned int Dist_L;
extern unsigned int Dist_R;
extern char Obs_L_Final;
extern char Obs_R_Final;
extern int New_Spline_Point_Arrived;
extern double Time_Out_Slow_Down;
extern unsigned char Lost_msg;
extern unsigned char Lost_msg_Slow_Down;

#define Obstacle_Left  (Dist_L > 600)
#define Obstacle_Right (Dist_R > 600)

char Check_Error_Rec_Coords(unsigned char* data );
void Send_Coord();
void Sort(unsigned int *arr,int i);
void ProxRead_m();
void Check_Wireless();
void Check_Battery(unsigned char FirstTime);

#endif/*_PIE_H_*/
