function Forces = itms_forces(X, Xo, s2, lambda)

    Nx = size(X,1);

    Forces = zeros(size(X));

    c1 = (1-lambda)/V(X, X, s2);
    c2 = 2*lambda/V(X, Xo, s2);
    
    for i=1:Nx
        Forces(i,:) = calc_forces(i, X, Xo, s2, c1, c2)/(Nx*Nx);
    end
        
end



function force = calc_forces(i, X, Xo, s2, c1, c2)

   
    xi = X(i,:);

    force = -(c1*F(xi,X, s2) + c2*F(xi,Xo,s2));
    
end


function force = F(xi, X, s2)

    Nx = size(X,1);

    force = zeros(size(X(1,:)));
    
    for j=1:Nx
        xoj = X(j,:);
        force = force + info_force(xi, xoj, s2);
    end

end


function f = info_force(xi, xj, s2)

    f = G(xi,xj,s2)*((xi-xj)/s2);

end


function y = V(X, Xo, s2)

    Nx = size(X,1);
    
    y = 0;
    for i=1:Nx
        for j=1:i
            xi = X(i,:);
            xoj = Xo(j,:);
            y = y + G(xi, xoj, s2);
        end
    end
    
   
    y = 2*y/(Nx^2);

end




function y = G(xi, xj, s2)

    Dx = size(xi,2);

    u = 0;
    for i=1:Dx
        u = u + (xi(i)-xj(i))^2;
    end
    y = exp(-u/s2);
    
end