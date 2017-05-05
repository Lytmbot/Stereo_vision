function [ corr_coeff ] = GET_2D_corr(im_A, im_B)
% IN
% 2*2D matrix  (gray scale images)

% OUT
% correlation coefficition, a single decimal value, for these matrix
% overlayed on each other perfectly.

N = numel(im_A); % num A elements

f_bar = mean(im_A(:));
g_bar = mean(im_B(:));

f_eval = im_A - f_bar;
g_eval = im_B - g_bar;

sig_f = sum(sum(f_eval.^2));
sig_g = sum(sum(g_eval.^2));
sig_f = sqrt((1/N)*(sig_f));
sig_g = sqrt((1/N)*(sig_g));

summed = sum(sum((f_eval.*g_eval)));

%% final corelation coeeficient
corr_coeff = (1/(N))*summed/(sig_f*sig_g);

end

