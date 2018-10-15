#include <stdio.h>
#include <math.h>
#include "mex.h"

/* To compile:

mex itms_forces_c.c

*/


// C mex file equivalent to itms_forces.m to speed up calculations
// for a clear code (in Matlab) please report to itms_forces.m
// this file does the same thing, but is written in C



/* Input */

#define	X_IN	prhs[0]
#define	Xo_IN	prhs[1]
#define	s2_IN	prhs[2]
#define	lambda_IN	prhs[3]

/* Output */

#define	Forces_OUT	plhs[0]
#define Forces(l,c) Forces[(l)+Forces_rows*(c)] // same


/* Matrix access */

#define X(l,c) X[(l)+Nx*(c)] // X_rows = number of lines in X
#define Xo(l,c) Xo[(l)+Nx*(c)] // Xo_rows = number of lines in Xo
#define s2(l,c) s2[(l)+s2_rows*(c)] // s2_rows = number of lines in s2
#define lambda(l,c) lambda[(l)+lambda_rows*(c)] // lambda_rows = number of lines in lambda


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





void info_force(double *xi, double *xj, double s2, int Nx, int Dx, double *f) {
    int k;
    
    for (k=0; k<Dx; k++) {
        f[k] = G(xi,xj,s2,Dx)*((xi[k]-xj[k])/s2);
    }

}


void F(double *xi, double *X, double s2, int Nx, int Dx, double *force) {

    int j, k;
    double xoj[MAX_D];
    double t_tmp[MAX_D];
    
    for(k=0;k<Dx;k++)
        force[k] = 0.0; 
    
    for (j=0; j<Nx; j++) {
        
        for(k=0;k<Dx;k++)
            xoj[k] = X(j,k);
            
        info_force(xi, xoj, s2, Nx, Dx, t_tmp);
        
        for(k=0;k<Dx;k++)
            force[k] += t_tmp[k];        
    }

}




void calc_forces(int i, double *X, double *Xo, double s2, double c1, double c2, int Nx, int Dx, double *Res) {
    
    double xi[MAX_D];
    double f_tmp1[MAX_D], f_tmp2[MAX_D];
    int k;
    
   
    for(k=0;k<Dx;k++)
        xi[k] = X(i,k);

    F(xi,X,s2,Nx,Dx,f_tmp1);
    F(xi,Xo,s2,Nx,Dx,f_tmp2);
    
    for(k=0;k<Dx;k++)
        Res[k] = -(c1*f_tmp1[k] + c2*f_tmp2[k])/(Nx*Nx);
}




void mexFunction( int nlhs, mxArray *plhs[],
		  int nrhs, const mxArray *prhs[] )
{
    int i,j,k;
    
    double c1, c2;
    
    double *Res;

    double *X;
    int *D_X, X_rows, X_cols;
    double *Xo;
    int *D_Xo, Xo_rows, Xo_cols;
    double *s2;
    int *D_s2, s2_rows, s2_cols;
    double *lambda;
    int *D_lambda, lambda_rows, lambda_cols;    
        
    int Nx, Dx;
    
    double *Forces;
    int Forces_rows, Forces_cols;    
    
    
// Transforms Matlab variables mx_array into
// *double variables

    X = mxGetPr(X_IN);
    Xo = mxGetPr(Xo_IN);
    s2 = mxGetPr(s2_IN);
    lambda = mxGetPr(lambda_IN);

// Size of the input matrices

    D_X = mxGetDimensions(X_IN);
    X_rows = D_X[0];
    X_cols = D_X[1];
    D_Xo = mxGetDimensions(Xo_IN);
    Xo_rows = D_Xo[0];
    Xo_cols = D_Xo[1];
    D_s2 = mxGetDimensions(s2_IN);
    s2_rows = D_s2[0];
    s2_cols = D_s2[1];
    D_lambda = mxGetDimensions(lambda_IN);
    lambda_rows = D_lambda[0];
    lambda_cols = D_lambda[1];
    

    Forces_rows = X_rows;
    Forces_cols = X_cols;
        
// create output matrices (in this example, the same size inputs)

    Forces_OUT = mxCreateDoubleMatrix(Forces_rows,Forces_cols,mxREAL);
    Forces = mxGetPr(Forces_OUT);

// here we go   


    Nx = X_rows;
    Dx = X_cols;
    

    c1 = (1.0-lambda(0,0))/V(X, X, s2(0,0), Nx, Dx);
    c2 = 2.0*lambda(0,0)/V(X, Xo, s2(0,0), Nx, Dx);
    
    Res = mxMalloc(Dx*sizeof(double));
    
    for (i=0;i<Nx;i++) {
        calc_forces(i, X, Xo, s2(0,0), c1, c2, Nx, Dx, Res);
        
        for(k=0;k<Dx;k++)
            Forces(i,k) = Res[k];
    }
    
    mxFree(Res);
        
    
// here we went   
   
}

