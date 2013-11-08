#ifndef _PWM_H_
#define _PWM_H_

int start_pwm(const char* path, unsigned long period, unsigned long duty, int polarity);

#endif