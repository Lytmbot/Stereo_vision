function [ sorted_1, sorted_2 ] = Get_sorted( indexed_1, indexed_2, dims )
%% Return the input as a column vector sorted into groups determined by dims
% and in decending order

sorted_1 = zeros(dims(1),dims(2));
sorted_2 = zeros(dims(1),dims(2));

%% break up into 2D cols21*rows17
j = 1;
for i=1 : dims(1) : size(indexed_1,1)-(dims(1)-1)
    
    sorted_1(:,j) = indexed_1(i:i+(dims(1)-1),1);
    sorted_2(:,j) = indexed_2(i:i+(dims(1)-1),1);   
    j = j+1;
end


%% sort each column
for i=1 : size(sorted_1,2) %columns 
    
    % store values in current column
    temp_x = sorted_1(:,i);
    temp_y = sorted_2(:,i);    
    
    [temp_y, SortIndex] = sort(temp_y);
    temp_x = temp_x(SortIndex);

    sorted_1(:,i) = temp_x;
    sorted_2(:,i) = temp_y;   

end

%% re-stack
sorted_1 = reshape(sorted_1,[dims(2)*dims(1),1]);
sorted_2 = reshape(sorted_2,[dims(2)*dims(1),1]);


%% END FUNCTION
end
