function [ dpx, dpy] = GET_2D_offset( imagea, imageb, wsize, xgrid, ygrid, dpx_est, dpy_est )
%%WHAT IT DOES:
%
% IN:
%       imagea = 2d array, int-> greyscale taken @ time = t
%       imageb = 2d array, int-> greyscale taken @ time = t+delta_t
%       (assume bototm left is [0,0])
%
%       wsize  = [1*2] vector where [x,y] are the respective interigation
%                window dimenions
%       xgrid  = [m*n] array of x-possitions for the centre of all
%                interigation windows
%       ygrid  = [m*n] array of y-possitions for the centre of all
%                interigation windows
%       
%       dpx_est = estimate of the shift of each cell in the x direction
%       dpy_est = estimate of the shift of each cell in the y direction
%
% OUT
%       dpx = [m*n] array of pixel displacment in the x direction
%       dpy = [m*n] array of pixel displacment in the y direction
%       (each displacment in dpx and dpy will correspond to the average
%       displacement of particles within the interigation windows centered
%       at the points described by xgrid and ygrid)

%% check is window even or odd
%  determine the window parameters
if mod(wsize(1),2) == 0
    x_trim_back = (wsize(1))/2;
    x_trim_front = (wsize(1)/2)-1;
else
    x_trim_back = (wsize(1)-1)/2;
    x_trim_front = (wsize(1)-1)/2;
end

if mod(wsize(2),2) == 0
    y_trim_back = (wsize(2))/2;
    y_trim_front = (wsize(2)/2)-1;
else
    y_trim_back = (wsize(2)-1)/2;
    y_trim_front = (wsize(2)-1)/2;
end

%% THE GUTS
dpx = zeros(size(xgrid,1),size(ygrid,2));
dpy = dpx;
m = 1;
n = 1;

for i = 1 : size(xgrid,1)
    for j = 1 : size(ygrid,2)
        
        %% get the sample window corners
        centre = [xgrid(i,j), ygrid(i,j)];
        x_1 = centre(1)-x_trim_back;
        x_2 = centre(1)+x_trim_front;
        y_1 = centre(2)-y_trim_back;
        y_2 = centre(2)+y_trim_front;
        sample = imagea(y_1:y_2,x_1:x_2); % image to find
        
        %% get the search window corners
        estimate = [dpx_est(n,m), dpy_est(n,m)];        
        x_1_est = x_1 + round(estimate(1));
        x_2_est = x_2 + round(estimate(1));
        y_1_est = y_1 + round(estimate(2));
        y_2_est = y_2 + round(estimate(2));
        target = imageb(y_1_est:y_2_est,x_1_est:x_2_est); % image to search

        %% multi grid dimension spreading        
        if mod(j,2) == 0
           m = m+1; 
        end
        
        
        %% get correlation map, find peak
        corr_map = normxcorr2(sample,target);
        %figure, surf(corr_map), shading flat
        
        % handle empty cell excpetion
        if max(corr_map(:)) == 0
            disp('no useful data in cell @')
            centre
            figure
            imshow(sample)
            figure
            imshow(target)
            
            disp('loop is @')
            i
            j
            
            dpx(i,j) = 0;
            dpy(i,j) = 0;
        else
            [ypeak, xpeak] = find(corr_map==max(corr_map(:)));
            
            %% out of bounds error handle
            if xpeak == 1
               xpeak = 2; 
            end
            if ypeak == 1
               ypeak = 2; 
            end
            if xpeak == size(corr_map(),2)
               xpeak = size(corr_map(),2) - 1; 
            end            
            if ypeak == size(corr_map(),1)
               ypeak = size(corr_map(),1) - 1; 
            end
            
            %% sub pixel investigation
            x_R_left = corr_map(ypeak,xpeak-1);
            x_R = corr_map(ypeak,xpeak);
            x_R_right = corr_map(ypeak,xpeak+1);
            x_tau = xpeak + 0.5*(log(x_R_left)-log(x_R_right))/(log(x_R_left)+log(x_R_right)- 2*log(x_R));
            
            y_R_left = corr_map(ypeak-1,xpeak);
            y_R = corr_map(ypeak,xpeak);
            y_R_right = corr_map(ypeak+1,xpeak);
            y_tau = ypeak + 0.5*(log(y_R_left)-log(y_R_right))/(log(y_R_left)+log(y_R_right)- 2*log(y_R));
            
            dpx(i,j) = x_tau - wsize(1) + estimate(1);
            dpy(i,j) = y_tau - wsize(2) + estimate(2);
                        
        end
        
        
    end
    %% multi grid dimension spreading        
        if mod(i,2) == 0
           n = n+1; 
        end
    m = 1;    
    
    % ticker to keep you hanging in there
    size(xgrid,1) - i
end

%% END FUNCTION
end

