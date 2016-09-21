function [ xyAdjust ] = MatchPointsIndividual( imInitial, xyOrig, imFrame, xyGuess )
%MatchPoints Match the x,y locations to the regions
%   Just find the closest points

nPts = size(xyOrig, 2);

xyAdjust = xyGuess;
for p = 1:nPts
    xyShift = MatchAll(imInitial, xyOrig(:,p), imFrame, xyGuess(:,p), 5, 10 );
    xyAdjust(1,p) = xyAdjust(1,p) + xyShift(1);
    xyAdjust(2,p) = xyAdjust(2,p) + xyShift(1);
end

end

