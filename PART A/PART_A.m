%% QUESTION 1.2

clear all

%% read in images
B_og = imread('Wizard_RGB.png');
A_og = imread('WheresWally_RGB.png');

% look for target in every position of A_og, no edge overlap
R = norm_corr_2D(B_og,A_og);

%% display corr map
figure, surf(R), shading flat

%% get peak coreleation index
[ypeak, xpeak] = find(R==max(R(:)));

% zoom in on peak
R_sub_plot = R(ypeak-10 : ypeak + 10, xpeak-10 : xpeak + 10);
R_sub_plot_y = R(ypeak-10 : ypeak + 10, xpeak(:));
R_sub_plot_x = R(ypeak(:), xpeak-10:xpeak+10);
figure, surf(R_sub_plot), shading flat

% Display matched area
figure
hAx  = axes;
imshow(A_og,'Parent', hAx);
rectangle(hAx, 'Position', [xpeak, ypeak, size(B_og,2), size(B_og,1)])

% get 1nd match area
match_1 = A_og(ypeak:size(B_og,1)+ypeak,xpeak:size(B_og,2)+xpeak);
imshow(match_1)


%% QUESTION 1.4
[ypeak_sub,xpeak_sub] = Get_sub_pixel(R);

%% QUESTION 1.5
R_next_peak = R;
% delete previous peak in R
R_next_peak(ypeak-10 : ypeak+10, xpeak-10 : xpeak+10) = 0;

% get 2nd match area
[ypeak_2nd, xpeak_2nd] = find(R_next_peak==max(R_next_peak(:)));
[ypeak_sub_2nd,xpeak_sub_2nd] = Get_sub_pixel(R_next_peak);
match_2 = A_og(ypeak:size(B_og,1)+ypeak,xpeak:size(B_og,2)+xpeak);
imshow(match_2)



