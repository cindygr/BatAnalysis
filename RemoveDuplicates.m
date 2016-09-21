function [ regsOut ] = RemoveDuplicates( regsIn, imTh, score )
%RemoveDuplicates Any region that's on top of another, keep only the one
%that is mostly thresholded pixels

nRegs = regsIn.Count;
if ~exist('score', 'var')
    score = zeros( nRegs, 1);
    for r = 1:nRegs
        score(r) = Overlap( regsIn.PixelList(r), imTh );
    end
end

keep = zeros( nRegs, 1 ) == 0;
dDistInsideSq = 4 * 4; % Pixel dist squared
for r1 = 1:nRegs
    for r2 = 1:nRegs
        loc1 = regsIn.Location(r1,:);
        loc2 = regsIn.Location(r2,:);
        dist = sum( (loc1 - loc2).^2 );
        if dist < dDistInsideSq
            if score(r1) < score(r2) 
                keep(r1) = false;
            end
        end
    end
end

regsOut = regsIn(keep);
end

