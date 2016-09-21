function [ score ] = Overlap( pixs, imTh )
%Overlap Sum up the values of the pixels in the region list
%   Detailed explanation goes here

score = 0;
for k = 1:size(pixs,1)
    score = score + double(imTh( pixs(k,2), pixs(k,1) )) / 255;
end

score = score / size(pixs,1);
end

