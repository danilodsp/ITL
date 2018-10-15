function extension1()
%
% Correntropy (Parzem x=y) demo
%
%   The goal is to find the parabola coefficients (a, b and c) to fit the
%   data. Mode the sliders to change the parameter and watch the p(x,y)
%   plot. As you find the right values, the integral in the line x=y gets
%   maximised (red plot under the blue surface)
%
% If you have any question, please send me an email (allan@dee.ufrn.br)



    close('all');

    
    
    F = figure();
    
    info_text = uicontrol('style','text','units','normalized','position',[0.025 0.41 0.45 0.05],'string','slide a, b and c to the correct values','fontsize',15);

    a_text = uicontrol('style','text','units','normalized','position',[0.025 0.11 0.05 0.05],'string','a','fontsize',20);
    b_text = uicontrol('style','text','units','normalized','position',[0.025 0.21 0.05 0.05],'string','b','fontsize',20);
    c_text = uicontrol('style','text','units','normalized','position',[0.025 0.31 0.05 0.05],'string','c','fontsize',20);
    
    a_slider = uicontrol('style','slider','units','normalized','position',[0.1 0.11 0.35 0.05]);
    b_slider = uicontrol('style','slider','units','normalized','position',[0.1 0.21 0.35 0.05]);
    c_slider = uicontrol('style','slider','units','normalized','position',[0.1 0.31 0.35 0.05]);
   
    N = 100;
   
    a = 0.5;
    b = 0.0;
    c = 0.5;
   
    a0 = 0.1;
    b0 = 0.0;
    c0 = 0.0;
   
    xi = randn(1,N);
    yi = a*xi.^2 + b*xi + c + randn(size(xi))*0.2;

    doomsDay = 0;
    while (~doomsDay) 
        if (ishandle(F))

            a0 = -2.0 + 4.0*get(a_slider,'value');
            b0 = -2.0 + 4.0*get(b_slider,'value');
            c0 = -2.0 + 4.0*get(c_slider,'value');
            
            plotOriginal(xi, yi, a, b, c, a0, b0, c0);
            plotExtension1in2D(xi,yi,a0, b0, c0);
            plotExtension1Parzen3D(xi, yi, a0, b0, c0, 0.05);
            
            drawnow();
        else
            doomsDay = 1;
        end
    end    
    
    close('all');
end



function plotOriginal(xi, yi, a, b, c, a0, b0, c0)
    
    t = -4:0.1:4;
    f = a*t.^2 + b*t +c;
    f0 = a0*t.^2 + b0*t +c0;
    
    subplot(2,2,1);
    cla();
    hold('on');
    plot(xi,yi,'ko');
    plot(t,f);    
    plot(t,f0,'r');

    xlabel('xi','fontsize',20);
    ylabel('yi','fontsize',20);
    
    title('original data','fontsize',20);
end


function plotExtension1in2D(xi, yi, a0, b0, c0)

    v1 = yi;
    v2 = a0*xi.^2 + b0*xi + c0;
    
    t = -4:1.0:4;
    
    subplot(2,2,2);
    cla();
    hold('on');
    plot(v1, v2,'ko');
    plot(t,t,'r');

    xlabel('v1=y1','fontsize',20);
    ylabel('v2=a*xi^2+b*xi+c','fontsize',20);

    title('data after "adaptation" for 1st extension','fontsize',20);
end


function plotExtension1Parzen3D(xi, yi, a0, b0, c0, s2)

    Nx = 80;
    Ny = 80;
    Nxy = 50;

    
    x = linspace(-4,4,Nx);
    y = linspace(-4,4,Ny);
    
    t = linspace(-4,4,Nxy);

    [z, w] = meshgrid(x,y);
    p = zeros(Nx,Ny);
    
    v1 = yi;
    v2 = a0*xi.^2 + b0*xi + c0;
    
    D = [v1; v2];
    
    
    ip = zeros(1,Nxy);
    for i=1:Nxy
        ip(i) = parzen(D,[t(i); t(i)], s2);
    end
    
    for i=1:Nx
        for j=1:Ny
            p(i,j) = parzen(D,[x(i); y(j)],s2);
        end
    end
    
    
    subplot(2,2,4);
    cla();
    hold('on');
    surf(z, w, p,'facealpha',0.5,'facecolor',[0.2 0.2 1.0],'edgecolor','none'); 
    camlight();
    plot3(v2, v1, zeros(size(v1)),'ok');
    plot3(t,t,zeros(size(t)),'r');
    patch(t,t,ip,'r','facealpha',0.7);
    
    axis([-4 4 -4 4 0 1]);
    
    grid('on');
    view(35,75);
    
    xlabel('v1','fontsize',20);
    ylabel('v2','fontsize',20);
    zlabel('p(v1, v2)','fontsize',20);
    
    title('parzen estimate of the adapted date','fontsize',20);
end