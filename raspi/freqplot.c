/* Plots a frequency spectrum for a circuit
 * Reinoso G.      2017/03/05
 *
 * Compile:
 *   gcc -lm -lwiringPi soft_i2c.c freqplot.c -o freqplot
 */

#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <wiringPi.h>
#include <string.h>
#include "soft_i2c.h"

#define CLKPIN  7

#define I2CADDR 0x48
#define I2CHAN  0x2

/* Fill an array with logarithmically spaced points. */
int logspace(double *result, int start, int stop, int n) {
	int i;
	double lstart = log(start);
	double lstop  = log(stop);

	double step = (lstop-lstart)/(n-1.0);

	for (i = 0; i <= (n-1); i++)
		result[i] = exp(lstart + i*step);

	return n;
}


void usagexit(char *name) {
	fprintf(stderr, 
			"Usage: %s npoints fstart fstop\n"
			"    npoints: number of points (approximate, use to be a bit less)\n"
			"    fstart:  start frequency\n"
			"    fstop:   end frequency\n",
			name
			);
	exit(1);
}


/* Main function */
int main (int argc, char **argv) {

	int fstart, fstop, npoints;

	fprintf(stderr, "Frequency plotter for Raspberry by Electronica y Ciencia\n");

	if(geteuid() != 0)
		fprintf(stderr, "Warning: usually this program requires root to work properly.\n");
	
	if (argc != 4)
		usagexit(argv[0]);

	npoints = atoi(argv[1]);
	fstart  = atoi(argv[2]);
	fstop   = atoi(argv[3]);
	
	if ( !npoints || !fstart || !fstop || (fstart > fstop) )
		usagexit(argv[0]);
	

	if (wiringPiSetup () == -1)
		return 1;

	pinMode(CLKPIN, GPIO_CLOCK);

	/* Init ADC */
	i2c_t i2c = i2c_init(9,8);

	// Send control register
	i2c_start(i2c);
	i2c_send_byte(i2c, I2CADDR << 1 | I2C_WRITE);
	i2c_send_byte(i2c, I2CHAN);
	i2c_stop(i2c);

	// Read and discard first A/D values
	i2c_start(i2c);
	i2c_send_byte(i2c, I2CADDR << 1 | I2C_READ);
	i2c_read_byte(i2c);


	/* start generating freqs */
	double freqs[npoints];
	logspace(freqs, fstart, fstop, npoints);

	int i;
	int lastf = 0;
	for (i = 0; i < npoints; i++) {

		int f = gpioClockSet(CLKPIN, (int)round(freqs[i]));
		
		if (f == lastf)
			continue;
		
		delayMicroseconds(1e3);

		i2c_send_bit(i2c, I2C_ACK); // store new value

		int v = i2c_read_byte(i2c); // read lastf's value

		if (lastf != 0)
			printf("%d\t%d\n", lastf, v);

		lastf = f;
	}

	i2c_send_bit(i2c, I2C_ACK); // store new value
	printf("%d\t%d\n", lastf, i2c_read_byte(i2c));

	i2c_stop(i2c);
}
