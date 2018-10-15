#include <stdio.h>
#include <math.h>
#include "mex.h"

/* To compile:

mex itms.c

*/


// C mex file equivalent to itms.m to speed up calculations
// for a clear code (in Matlab) please report to itms.m
// this file does the same thing, but is written in C


/* Input */

#define	Xinit_IN	prhs[0]
#define	Xo_IN	prhs[1]
#define	s2_IN	prhs[2]
#define	lambda_IN	prhs[3]
#define	Niter_IN	prhs[4]

/* Output */

#define	Xfinal_OUT	plhs[0]
#define Xfinal(l,c) Xfinal[(l)+Xfinal_rows*(c)] // same


/* Matrix access */

#define Xinit(l,c) Xinit[(l)+Xinit_rows*(c)] // Xinit_rows = number of lines in Xinit
#define s2(l,c) s2[(l)+s2_rows*(c)] // s2_rows = number of lines in s2
#define lambda(l,c) lambda[(l)+lambda_rows*(c)] // lambda_rows = number of lines in lambda
#define Niter(l,c) Niter[(l)+Niter_rows*(c)] // Niter_rows = number of lines in Niter

#define X(l,c) X[(l)+Nx*(c)] 
#define Xo(l,c) Xo[(l)+Nx*(c)] 
#define Xres(l,c) Xres[(l)+Nx*(c)] 
#define Xfinal2(l,c) Xfinal2[(l)+Nx*(c)] 

//
// WORKS ONLY UP TO MAX_D DIMENSIONS DATA SETS!!!!!
//
#define MAX_D 10


double G(double *xi, double *xj, double s2, int Dx) {
    double y, u;
    int i;
    
    u = 0.0;
    for (i=0;i<Dx;i++) {
        u += (xi[i]-xj[i])*(xi[i]-xj[i]);
    }
    y = exp(-u/s2);
        
    return y;
}





double V(double *X, double *Xo, double s2, int Nx, int Dx) {
    double y;
    int i, j, k;
    double xi[MAX_D], xoj[MAX_D];

    y = 0.0;
    for (i=0; i<Nx; i++) {
        for (j=0; j<Nx; j++) {
            for (k=0; k<Dx; k++) {
                xi[k] = X(i,k);
                xoj[k] = Xo(j,k);
            }
            y += G(xi, xoj, s2, Dx);
        }
    }
    
    y = y/(Nx*Nx);

    return 2.0*y;
}


void iterate(double *X, double *Xo, double s2, double lambda, double *Xres, int Nx, int Dx) {

    double c1, c2;
    int i, j, k;
    double sum1[MAX_D], sum2[MAX_D], sum3, sum4, xi[MAX_D], xj[MAX_D], xoj[MAX_D]; 
    double gj, goj;
    
    c1 = (1.0-lambda)/V(X, X, s2, Nx, Dx);
    c2 = 2.0*lambda/V(X, Xo, s2, Nx, Dx);


    for (i=0; i<Nx; i++) {
    
        for (k=0; k<Dx; k++) {
            sum1[k] = 0.0;
            sum2[k] = 0.0;
        }
        sum3 = 0.0;
        sum4 = 0.0;
        
        for (j=0; j<Nx; j++) {
            
            for (k=0; k<Dx; k++) {
                xi[k] = X(i,k);
                xj[k] = X(j,k);
                xoj[k] = Xo(j,k);
            }
            
            gj = G(xi,xj,s2, Dx);
            goj = G(xi,xoj,s2, Dx);
            
            for (k=0; k<Dx; k++) {
                sum1[k] += gj*xj[k];
                sum2[k] += goj*xoj[k];
            }
            sum3 += gj;
            sum4 += goj;
        }
        
        for (k=0; k<Dx; k++) {
            Xres(i,k) = (c1*sum1[k] + c2*sum2[k])/(c1*sum3 + c2*sum4);
        }
        
    }
}



void mexFunction( int nlhs, mxArray *plhs[],
		  int nrhs, const mxArray *prhs[] )
{
    int i,j, k;
    

    double *Xinit;
    int *D_Xinit, Xinit_rows, Xinit_cols;
    double *Xo;
    int *D_Xo, Xo_rows, Xo_cols;
    double *s2;
    int *D_s2, s2_rows, s2_cols;
    double *lambda;
    int *D_lambda, lambda_rows, lambda_cols;
    double *Niter;
    int *D_Niter, Niter_rows, Niter_cols;    
        
    int Nx, Dx;

    double *Xfinal;
    int Xfinal_rows, Xfinal_cols;    
    
    
// Transforms Matlab variables mx_array into
// *double variables

    Xinit = mxGetPr(Xinit_IN);
    Xo = mxGetPr(Xo_IN);
    s2 = mxGetPr(s2_IN);
    lambda = mxGetPr(lambda_IN);
    Niter = mxGetPr(Niter_IN);

// Size of the input matrices

    D_Xinit = mxGetDimensions(Xinit_IN);
    Xinit_rows = D_Xinit[0];
    Xinit_cols = D_Xinit[1];
    D_Xo = mxGetDimensions(Xo_IN);
    Xo_rows = D_Xo[0];
    Xo_cols = D_Xo[1];
    D_s2 = mxGetDimensions(s2_IN);
    s2_rows = D_s2[0];
    s2_cols = D_s2[1];
    D_lambda = mxGetDimensions(lambda_IN);
    lambda_rows = D_lambda[0];
    lambda_cols = D_lambda[1];
    D_Niter = mxGetDimensions(Niter_IN);
    Niter_rows = D_Niter[0];
    Niter_cols = D_Niter[1];
    
    Nx = D_Xinit[0];
    Dx = D_Xinit[1];

    Xfinal_rows = Nx;
    Xfinal_cols = Dx;
        
// create output matrices (in this example, the same size inputs)

    Xfinal_OUT = mxCreateDoubleMatrix(Xfinal_rows,Xfinal_cols,mxREAL);
    Xfinal = mxGetPr(Xfinal_OUT);

// here we go   
    
    iterate(Xinit, Xo, s2(0,0), lambda(0,0), Xfinal, Nx, Dx);
// here we went   
   
}

