%% unique peaks junk



%% Y NEIGHBOURS
i=1;
while i < size(ypeaks,1)
    
    %check for tolerance violation in peak spaceing
    spacing = abs(ypeaks(i) - ypeaks(i+1));
    
    if spacing <= prox_tol
        % check peaks
        if R(ypeaks(i),xpeaks(i)) < R(ypeaks(i+1),xpeaks(i+1))
            ypeaks(i+1) = [];
            xpeaks(i+1) = [];
        else
            ypeaks(i) = [];
            xpeaks(i) = [];
        end
        i = i-1; % for the lost index
        if i < 1
            i = 1;
        end
    end
    i = i+1;
end


%% X NEIGHBOURS
i=1;
[ypeaks, SortIndex] = sort(ypeaks);
 xpeaks = xpeaks(SortIndex);

while i < size(xpeaks,1)
    
    %check for tolerance violation in peak spaceing
    spacing = abs(xpeaks(i) - xpeaks(i+1));
    
    if spacing <= prox_tol
        % check peaks
        if R(ypeaks(i),xpeaks(i)) < R(ypeaks(i+1),xpeaks(i+1))
            ypeaks(i+1) = [];
            xpeaks(i+1) = [];
        else
            ypeaks(i) = [];
            xpeaks(i) = [];
        end
        i = i-2; % for the lost index
    end
    i = i+1;
end
