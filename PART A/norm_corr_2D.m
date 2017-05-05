function [ R ] = norm_corr_2D( im_A, im_B )
%% DESCRIPTION
%       Takes two images and builds a 2D matrix of correlation coeffitent
%       values itterating im_B over sub_sections of im_A

%  IN:
%       im_A, base image to search within
%       im_B, target image to search for

% OUT:
%       2D matrix of R values


B = rgb2gray(im_A);
A = rgb2gray(im_B);

%pre allocate R
R = zeros(size(A,1) - size(B,1),size(A,2) - size(B,2));

% look for target in every position of A_og, no edge overlap
target = B;
for y = 1 : size(A,1) - size(B,1)
    for x = 1 : size(A,2) - size(B,2)
        
        sample = A(y:(size(B,1)+y-1), x:(size(B,2) + x -1));
        R(y,x) = GET_2D_corr(sample,target);
        
    end
    y
end


end

