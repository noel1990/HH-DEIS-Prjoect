/* odometry header */
#ifndef _ODOMETRY_H_
#define _ODOMETRY_H_

#define PI                3.1415926535897932384626433832795
#define TICKS_PER_SECOND  20
#define WHEEL_DISTANCE    204.4
#define MM_PER_TICK       0.86
#define dt                0.1

extern double curx;
extern double cury;
extern double curtheta;
extern double piecurv;

//void PFC(double goalx, double goaly, double goaltheta);
double wrapAngle(double angle);
void feedbackController(double goalx, double goaly, double goaldist);
double wrapAngle(double angle);
void odometry(char fristTime);

//typedef struct {
//	double x;
//	double y;
//	double angle;
//} od_pos_t;
//
//typedef struct {
//	double v;
//	double w;
//} od_speed_t;
//


#endif /* _ODOMETRY_H_ */
