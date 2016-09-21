function [ xyAdjust ] = MatchAllTemplates( imTemplates, imFrame, xyGuess, pad, padSearch )
%MatchAllTemplates Summary of this function goes here
%   Detailed explanation goes here

nPts = size(xyGuess, 2);

xyAdjust = xyGuess;
for p = 1:nPts
    xyShift = MatchTemplate(imTemplates{p,1}, imTemplates{p,2}, imTemplates{p,3}, imFrame, xyGuess(:,p), pad, padSearch );
    xyAdjust(1,p) = xyAdjust(1,p) + xyShift(1);
    xyAdjust(2,p) = xyAdjust(2,p) + xyShift(1);
end

end

