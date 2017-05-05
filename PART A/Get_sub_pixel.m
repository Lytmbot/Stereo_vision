function [ sub_y, sub_x ] = Get_sub_pixel( R_map )
%Fit a 3 point Guassian curve to find peak to sub pixel accuraacy
%
%  In:
%       3d matrix, x y are coords z is value


% OUT:
%       sub_y = sub_pixel peak in y
%       sub_x = sub_pixel peak in x


[ypeak, xpeak] = find(R_map==max(R_map(:)));

            x_R_left = R_map(ypeak,xpeak-1);
            x_R = R_map(ypeak,xpeak);
            x_R_right = R_map(ypeak,xpeak+1);
            sub_x = xpeak + 0.5*(log(x_R_left)-log(x_R_right))/(log(x_R_left)+log(x_R_right)- 2*log(x_R));
            
            y_R_left = R_map(ypeak-1,xpeak);
            y_R = R_map(ypeak,xpeak);
            y_R_right = R_map(ypeak+1,xpeak);
            sub_y = ypeak + 0.5*(log(y_R_left)-log(y_R_right))/(log(y_R_left)+log(y_R_right)- 2*log(y_R));
            
end

