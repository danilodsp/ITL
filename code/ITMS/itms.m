function Xfinal = itms(Xinit, s2, lambda, Niter)

    Xfinal = Xinit;
    
    for i=1:Niter
        Xfinal = iterate(Xfinal, Xinit, s2, lambda);
        
        disp([num2str(i) ' of ' num2str(Niter)])
    end
        
end



function Xfinal = iterate(X, Xo, s2, lambda)

    Nx = size(X,1);

    c1 = (1-lambda)/V(X, X, s2);
    c2 = 2*lambda/V(X, Xo, s2);


    Xfinal = zeros(size(X));
    
    for i=1:Nx
    
        sum1 = zeros(size(X(1,:)));
        sum2 = zeros(size(X(1,:)));
        sum3 = 0;
        sum4 = 0;
        for j=1:Nx
            xi = X(i,:);
            xj = X(j,:);
            xoj = Xo(j,:);
            
            gj = G(xi,xj,s2);
            goj = G(xi,xoj,s2);
            
            sum1 = sum1 + gj*xj;
            sum2 = sum2 + goj*xoj;
            sum3 = sum3 + gj;
            sum4 = sum4 + goj;
        end

        Xfinal(i,:) = (c1*sum1 + c2*sum2)/(c1*sum3 + c2*sum4);
        
    end
end


function y = V(X, Xo, s2)

    Nx = size(X,1);
    
    y = 0;
    for i=1:Nx
        for j=1:Nx
            xi = X(i,:);
            xoj = Xo(j,:);
            y = y + G(xi, xoj, s2);
        end
    end
    
   
    y = y/(Nx^2);

end




function y = G(xi, xj, s2)

    Dx = size(xi,2);

    u = 0;
    for i=1:Dx
        u = u + (xi(i)-xj(i))^2;
    end
    y = exp(-u/s2);
    
end