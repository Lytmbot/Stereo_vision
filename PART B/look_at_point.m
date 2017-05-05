


%% look at point
% 
% for q = 1 : size(x_right_col)
%         
%     scatter3(x_right_col(q),y_right_col(q), z_real(q));
%     hold on
%     pause(0.1)
% end
%        
% hold off
%         
       
figure, plot3(x_right_col,y_right_col,z_real);
title('peaks isopated from images')
figure, plot3(x_real,y_real,z_real);
title('actual points')