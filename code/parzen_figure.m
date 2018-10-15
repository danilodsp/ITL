Nx = 50;
Ny = 50;

D = [randn(2,1000)];

s2 = 0.1;

[x, y] = meshgrid(linspace(-3,3,Nx),linspace(-3,3,Ny));


for i=1:Nx
    for j=1:Ny
        p1(i,j) = parzen(D,[x(i,j); y(i,j)],s2);
    end
end







Nx = 100;

D = [randn(1,100) 6+0.5*randn(1,300)];

x = linspace(-4,8,Nx);

for i=1:Nx
    p2(i) = parzen(D,x(i),s2);
end
