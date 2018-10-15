#include <stdio.h>
#include <math.h>
#include "mex.h"


/* To compile:

mcc parzen.c

% Estimates the probability p(x) given a set of data points using parzen windows
%
% D -> Data set
% x -> point where you need to compute the probability
% s2 -> kernel size


*/

#define PI 3.14159265358979

/* Argumentos de entrada*/
#define	D_IN	prhs[0]
#define	x_IN	prhs[1]
#define	s2_IN	prhs[2]

/* Argumentos de Saida*/
#define	p_OUT	plhs[0]


double phi(double x[], double s2, int m)
{
// Calcula a probabilidade p(x) para uma gaussiana com variancia igual a
// identidade
//
//  lembrar que e m-dimensional
//

double arg, p;
int i;

arg = 0.0;
for(i=0; i<m; i++)
   arg += x[i]*x[i];

p = 1.0/pow((s2*2.0*PI),((double)(m)/2.0));

p *= exp(-(arg)/(2.0*s2));

return p;
}

/* Funcao principal (entry point do Matlab) */
void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{
    int i,j,c, *dim;
    double *D, *x, *s2;  // input parameters
    double *p; // output parameters
    double *arg, Vn, n, d, hn;

// Transforma as variaveis do Matlan mx_array em
// variaveis que podem ser facilmente manipuladas
    D = mxGetPr(D_IN);
    x = mxGetPr(x_IN);
    s2 = mxGetPr(s2_IN);

// Tamanho das matrizes de entrada
// dim -> tamanho de D
    dim = mxGetDimensions(D_IN);

  
    p_OUT = mxCreateDoubleMatrix(1,1,mxREAL);
    p = mxGetPr(p_OUT);


// here we go   

#define D(l,c) D[l+dim[0]*c]

d = dim[0];
n = dim[1];

arg = (double *)mxMalloc(d*sizeof(double)); 


p[0] = 0;
for(i=0; i<n; i++)
{
    for(j=0; j<d; j++) 
        arg[j] = (x[j]-D(j,i));
    
    p[0] += phi(arg,*s2,d);
}
p[0] /= n;


mxFree(arg);    
// here we went   
   
}





