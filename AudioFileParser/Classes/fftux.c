/*
 *  fftux.c
 *  AudioFileParser
 *
 *  Created by Steven Hooley on 16/01/2010.
 *  Copyright 2010 Tinsal Parks. All rights reserved.
 *
 */

#include "fftux.h"

// FFTW demo with wav file
// (C) 2005 www.captain.at

#include <stdio.h>
#include <stdlib.h>
#include "fftw3.h"

static double *rdata = NULL, *idata = NULL;
static fftw_plan rplan, iplan;
static int last_fft_size = 0;

double A[8192];
int n = 8192;

int i,m,k;
char erg[35];
char erg2[35];
double absval;
int is16bitfile = 1;

int main() {
	double cc;
	int v, val, val2;
	char inc[n];
	FILE *infile;
	FILE *file;
	FILE *file2;
	int samplerate = 44100;
	int bandwidth = samplerate / 2;
	int nhalf = n / 2;
	double correction = (double)samplerate / (double)n;
	
	infile = fopen("theevent-zoom.wav", "r");
	file = fopen("data.dat", "w");
	file2 = fopen("data.raw", "w");
	// skip wav file header
	fgets(inc,37,infile);
	fgets(inc,9,infile);
	
	// read data and fill "A"-array
	for (v=0;v<n;v++) {
		val = fgetc(infile);
		if (is16bitfile) {
			val2 = fgetc(infile);
			if (val2 > 127) { val2 = val2 - 255; }
			A[v] = 256*val2 + val;
		} else {
			A[v] = val;
		}
		sprintf(erg2, "%d %f\n", v, A[v]);
		fputs(erg2, file2);
	}
	
	// prepare fft with fftw
	rdata = (double *)fftw_malloc(n * sizeof(double));
	idata = (double *)fftw_malloc(n * sizeof(double));
	// create the fftw plan
	rplan = fftw_plan_r2r_1d(n, rdata, idata, FFTW_R2HC, FFTW_FORWARD); 
	
	// we have no imaginary data, so clear idata
	memset((void *)idata, 0, n * sizeof(double));
	// fill rdata with actual data
	for (i = 0; i < n; i++) { rdata[i] = A[i]; }
	// make fft
	fftw_execute(rplan);
	
	// post-process FFT data: make absolute values, and calculate
	//   real frequency of each power line in the spectrum
	m = 0;
	for (i = 0; i < (n-2); i++) {
		absval = sqrt(idata[i] * idata[i]);
		cc = (double)m * correction;
		sprintf(erg, "%f %f\n", cc, absval);
		fputs(erg, file);
		m++;
	}
	
	// housekeeping
	fclose(file);
	fclose(file2);
	fclose(infile);
	fftw_destroy_plan(rplan);
	fftw_free(rdata);
	fftw_free(idata);
	return 1;
}