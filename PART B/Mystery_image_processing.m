%% QUESTION 2.2

%% LOOKING AT THE TEST IMAGES
im_test_left  = rgb2gray(imread('test_images/test_left_2.tiff'));
im_test_right = rgb2gray(imread('test_images/test_right_2.tiff'));



%% get pixel displcement
%first pass
wsize = [64,64];
[X,Y] = meshgrid(100:64:2368,100:64:1792);
est1_dpx = zeros(size(X));
est1_dpy = zeros(size(Y));

[dpx_est2,dpy_est2] = GET_2D_offset(im_test_left,im_test_right,wsize,X,Y,est1_dpx,est1_dpy);

% second pass
wsize = [32,32];
[X,Y] = meshgrid(100:32:2336,100:32:1760);
[dpx,dpy] = GET_2D_offset(im_test_left,im_test_right,wsize,X,Y,dpx_est2,dpy_est2);


% pixel displacement in dpx and dpy become peak shifts in right image
x_left = X;
y_left = Y;
x_right = x_left + real(dpx);
y_right = y_left + real(dpy);

% get coefficient for A1-A15
Coeffs = zeros(size(y_right,1), 15);
k=1;
for i = 1 : size(y_right,2)
    for j = 1 : size(y_right,1)
        xl = x_left(j,i);
        yl = y_left(j,i);
        xr = x_right(j,i);
        yr = y_right(j,i);
        
        Coeffs(k,:) = [ 1, xl, yl, xr, yr, ...
            xl*yl, xl*xr, xl*yr, xr*yl, yl*yr, xr*yr, ...
            xl^2, yl^2, xr^2, yr^2];
        k=1+k;
    end
end

x_real_myst=Coeffs*Ax;
y_real_myst=Coeffs*Ay;
z_real_myst=Coeffs*Az;

sf = fit( [x_real_myst,y_real_myst],z_real_myst,'poly23');
plot(sf, [x_real_myst,y_real_myst],z_real_myst)

