function [ ypeaks, xpeaks ] = GET_unique_peaks( R, prox_tol, R_tol  )
%DESCRIPTION
% -gets local peaks in R as ypeak xpeak
% -compares elementwise along peak indexes for  proximity that violates
%  tolerance minimum
% -compare R(y(i),x(i)) and R(y(j),x(j)), remove the lesser x,y index

%  IN:
%       R        = 2D matrix of values to search for peaks
%       prox_tol = proximity tollerance for neighbouring peaks
%       R_tol    = value heald in R that above which is considered a
%                  peak

% OUT:
%       ypeaks = y indexes in R where a peak occurs
%       xpeaks = x indexes in R where a peak occurs

% get peaks
[ypeaks, xpeaks] = find(R >= (max(R(:) - max(R(:))*R_tol )));


%% ELEMENT BY ELEMENT
i = 1;
while i < size(xpeaks,1)
    
    %check for tolerance violation in peak spaceing
    j = i+1;
    while j <= size(xpeaks,1)
        spacing_x = abs(xpeaks(i) - xpeaks(j));
        spacing_y = abs(ypeaks(i) - ypeaks(j));
        
        if (spacing_x <= prox_tol ) && (spacing_y <= prox_tol )
            % check peaks
            if R(ypeaks(i),xpeaks(i)) < R(ypeaks(j),xpeaks(j))
                ypeaks(j) = [];
                xpeaks(j) = [];    
                j = j-1;
                if j < 1
                    j = 1;
                end
            else
                ypeaks(i) = [];
                xpeaks(i) = [];      
                i = i-1;
                if i < 1
                    i = 1;
                end
            end
        end
        j = j+1;
    end
    i = i+1;
end

%% re-sort by acending column



%% END FUNCYION
end

