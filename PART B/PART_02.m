%% PART 02

clear all

%% generate the calibration grid in real coordinate
[y_grid, x_grid] = meshgrid(0:50:800,-500:50:500);
z_grid = ones(357,6);

for z = 1 :6
    z_grid(:,z) = z_grid(:,z)*(2000-(z-1)*20);
end

% convert the solution matrix to 1D column
x_grid_straight = reshape(x_grid,[357,1]);
y_grid_straight = reshape(y_grid,[357,1]);

[x_grid_straight, SortIndex] = sort(x_grid_straight);
y_grid_straight = y_grid_straight(SortIndex);

% dont ask
x_real = vertcat(x_grid_straight,x_grid_straight,x_grid_straight,...
                 x_grid_straight,x_grid_straight,x_grid_straight);
y_real = vertcat(y_grid_straight,y_grid_straight,y_grid_straight,...
                 y_grid_straight,y_grid_straight,y_grid_straight);
z_real = vertcat(z_grid(:,1),z_grid(:,2),z_grid(:,3),z_grid(:,4),z_grid(:,5),z_grid(:,6));

% scatter3(x_real(:),z_real(:),y_real(:))


%% make a template which is a 2D Gaussian dot
dsize = 15;
sigi = dsize./2.5;
sigj = dsize./2.5;
[it,jt] = meshgrid([-dsize:1:dsize], [-dsize:1:dsize]);
template = 255*exp(-(((it).^2)./(2*sigi.^2) + ((jt).^2)./(2*sigj.^2)));

im_left = [];
im_right = [];

%% IMPORT IMAGES
for z=1:6
    % Reads the calibration images
    im_left{z}  = rgb2gray(imread(sprintf('calibration_images/cal_image_left_%d.tiff', (2000-(z-1)*20))));
    im_right{z} = rgb2gray(imread(sprintf('calibration_images/cal_image_right_%d.tiff',(2000-(z-1)*20))));
    figure, imshowpair(im_left{z},im_right{z},'montage')
end


%% GET CALIBRATION POINT LOCATIONS
% result is x_peaks, y_peaks positions for left and right images stored in
% the format y_left(peak possitions, image index) etc...
% so for image set 1 correlated set of peaks would be:
%   y_left(:,1)  x_left(:,1)
%   y_right(:,1) x_right(:,1)

% pre allocate variables
R_right = cell(6,size(im_right{1},1)+size(template,1),size(im_right{1},2)+size(template,2));
R_left  = cell(6,size(im_right{1},1)+size(template,1),size(im_right{1},2)+size(template,2));

% need to know how many dots there are ahead of time #375=17*21
x_right = zeros(357,6);
y_right = zeros(357,6);
x_left = zeros(357,6);
y_left = zeros(357,6);

for z=1:6
    R_right{z} = normxcorr2(template,im_right{z});
    R_left{z}  = normxcorr2(template,im_left{z});
    
    [y_right(:,z), x_right(:,z)] = GET_unique_peaks(R_right{z},30,0.013);
    [y_left(:,z),  x_left(:,z)]  = GET_unique_peaks(R_left{z},30,0.013);
    
    % remove the offset from norm x corr starting with single pixel overlap
    y_right(:,z) = y_right(:,z)-size(template,1);
    x_right(:,z) = x_right(:,z)-size(template,2);
    y_left(:,z) = y_left(:,z)-size(template,1);
    x_left(:,z) = x_left(:,z)-size(template,2);    
end

%% Sort the values by column
for i = 1 : 6
    [x_left(:,i), y_left(:,i)] = Get_sorted(x_left(:,i), y_left(:,i), [17,21]);
    [x_right(:,i), y_right(:,i)] = Get_sorted(x_right(:,i), y_right(:,i), [17,21]);
end

%% concatinate into column vectors to match real
x_right_col = reshape(x_right,numel(x_right),1);
y_right_col = reshape(y_right,numel(y_right),1);
x_left_col = reshape(x_left,numel(x_left),1);
y_left_col = reshape(y_left,numel(y_left),1);

%figure, scatter3(x_right_col(:),z_real(:),y_right_col(:))
%figure, scatter3(x_left_col(:),z_real(:),y_left_col(:))


%% GETTING x(ir,il,jl,jr) etc...
Coeffs = zeros(size(y_right_col,1), 15);
Coeffs_z = zeros(size(y_right_col,1), 11);
for i = 1 : size(y_right_col,1)
    xr = x_right_col(i);
    yr = y_right_col(i);
    xl = x_left_col(i);
    yl = y_left_col(i);
    
    Coeffs(i,:) = [ 1, xl, yl, xr, yr, ...
                    xl*yl, xl*xr, xl*yr, yl*xr, yl*yr, xr*yr, ...
                    xl^2, yl^2, xr^2, yr^2];    
                
end

% solve A1-A15 with nlinefit
modelfunc_x = @(Ax,Coeffs)(Ax(1)*Coeffs(:,1)+Ax(2)*Coeffs(:,2)...
    +Ax(3)*Coeffs(:,3)+Ax(4)*Coeffs(:,4)+Ax(5)*Coeffs(:,5)...
    +Ax(6)*Coeffs(:,6)+Ax(7)*Coeffs(:,7)+Ax(8)*Coeffs(:,8)...
    +Ax(9)*Coeffs(:,9)+Ax(10)*Coeffs(:,10)+Ax(11)*Coeffs(:,11)...
    +Ax(12)*Coeffs(:,12)+Ax(13)*Coeffs(:,13)+Ax(14)*Coeffs(:,14)...
    +Ax(15)*Coeffs(:,15));
Ax = nlinfit(Coeffs,x_real,modelfunc_x,zeros(15,1));

modelfunc_y = @(Ay,Coeffs)(Ay(1)*Coeffs(:,1)+Ay(2)*Coeffs(:,2)...
    +Ay(3)*Coeffs(:,3)+Ay(4)*Coeffs(:,4)+Ay(5)*Coeffs(:,5)...
    +Ay(6)*Coeffs(:,6)+Ay(7)*Coeffs(:,7)+Ay(8)*Coeffs(:,8)...
    +Ay(9)*Coeffs(:,9)+Ay(10)*Coeffs(:,10)+Ay(11)*Coeffs(:,11)...
    +Ay(12)*Coeffs(:,12)+Ay(13)*Coeffs(:,13)+Ay(14)*Coeffs(:,14)...
    +Ay(15)*Coeffs(:,15));
Ay = nlinfit(Coeffs,y_real,modelfunc_y,zeros(15,1));

modelfunc_z = @(Az,Coeffs)(Az(1)*Coeffs(:,1)+Az(2)*Coeffs(:,2)...
    +Az(3)*Coeffs(:,3)+Az(4)*Coeffs(:,4)+Az(5)*Coeffs(:,5)...
    +Az(6)*Coeffs(:,6)+Az(7)*Coeffs(:,7)+Az(8)*Coeffs(:,8)...
    +Az(9)*Coeffs(:,9)+Az(10)*Coeffs(:,10)+Az(11)*Coeffs(:,11))...
    +Az(12)*Coeffs(:,12)+Az(13)*Coeffs(:,13)+Az(14)*Coeffs(:,14)...
    +Az(15)*Coeffs(:,15);
Az = nlinfit(Coeffs,z_real,modelfunc_z,zeros(15,1));

% solve simultaniouse for A1-A15
A_x = Coeffs\x_real;
A_y = Coeffs\y_real;
A_z = Coeffs\z_real;

% go back and check solved coords from calibration images
x_solved1=Coeffs*Ax;
y_solved1=Coeffs*Ay;
z_solved1=Coeffs*Az;

x_solved2=Coeffs*A_x;
y_solved2=Coeffs*A_y;
z_solved2=Coeffs*A_z;

figure, scatter3(x_solved1,y_solved1, z_solved1,'filled');

for i = 1 : 357 : size(x_solved1,1)-1
    sf_1 = fit( [x_solved1(i:i+357-1),y_solved1(i:i+357-1)],z_solved1(i:i+357-1),'poly23');
    plot(sf_1, [x_solved1(i:i+357-1),y_solved1(i:i+357-1)],z_solved1(i:i+357-1))
    hold on
end
hold off


% error assesment
x_error = abs(x_solved1 - x_real);
y_error = abs(y_solved1 - y_real);
z_error = abs(z_solved1 - z_real);
index = 1:1:2142;

figure, plot(index,x_error)
hold on 
plot(index,y_error)
plot(index,z_error)


%% LOOKING AT THE TEST IMAGES
im_test_right = rgb2gray(imread('test_images/test_right_1.tiff'));
im_test_left  = rgb2gray(imread('test_images/test_left_1.tiff'));

%% get peaks
R_test_right = normxcorr2(template,im_test_right);
R_test_left  = normxcorr2(template,im_test_left);

[y_test_right, x_test_right] = GET_unique_peaks(R_test_right,30,0.015);
[y_test_left,  x_test_left]  = GET_unique_peaks(R_test_left,30,0.015);

% remove the offset from norm x corr starting with single pixel overlap
y_test_right = y_test_right-size(template,1);
x_test_right = x_test_right-size(template,2);
y_test_left = y_test_left-size(template,1);
x_test_left = x_test_left-size(template,2);

% sort images by column decending
[x_test_right, y_test_right] = Get_sorted(x_test_right, y_test_right,[9,13]);
[x_test_left,  y_test_left]  = Get_sorted(x_test_left, y_test_left,[9,13]);

% get coefficients
Coeffs_test = zeros(size(y_test_right,1), 15);
Coeffs_test_z = zeros(size(y_test_right,1), 11);
for i = 1 : size(y_test_right,1)
    xr = x_test_right(i);
    yr = y_test_right(i);
    xl = x_test_left(i);
    yl = y_test_left(i);
    
    Coeffs_test(i,:) = [ 1, xl, yl, xr, yr, ...
        xl*yl, xl*xr, xl*yr, xr*yl, yl*yr, xr*yr, ...
        xl^2, yl^2, xr^2, yr^2];    
    
    Coeffs_test_z(i,:) = [ 1, xl, yl, xr, yr, ...
        xl*yl, xl*xr, xl*yr, xr*yl, yl*yr, xr*yr];
end

% re use solved A1-A15
x_test_real=Coeffs_test*Ax;
y_test_real=Coeffs_test*Ay;
z_test_real=Coeffs_test*Az;

sf_test = fit( [x_test_real,y_test_real],z_test_real,'poly23');
figure, plot(sf_test, [x_test_real,y_test_real],z_test_real)
axis equal

