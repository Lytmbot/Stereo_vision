k = 1;
for z = 1 : 6
    Coeffs = zeros(size(y_right,1)*6, 15);
    for i = 1 : size(y_right,1)
        xl = x_left(i,z);
        yl = y_left(i,z);
        xr = x_right(i,z);
        yr = y_right(i,z);
        
        Coeffs(k,:) = [ 1, xl, yl, xr, yr, ...
            xl*yl, xl*xr, xl*yr, xr*yl, yl*yr, xr*yr, ...
            xl^2, yl^2, xr^2, yr^2];
        k = k+1;
    end
end