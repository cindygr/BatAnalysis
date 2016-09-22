function [ xyAdjust, err, bOutOfBds ] = MatchAllTemplates( imTemplates, imFrame, xyGuess, pad, padSearch )
%MatchAllTemplates Move each template in turn
%   imTemplates: One cutout for each point (image, rectangle, points)
%   imFrame: Input frame
%   xyGuess: Initial guess for point locations
%    pad/padSearch how much template is padded by, how big to search over
%
% Use ImageTemplates to set up the imTemplates data structure

nPts = size(xyGuess, 2);

xyAdjust = xyGuess;
err = 0;

padEdge = padSearch - 2;
bOutOfBds = false;
for p = 1:nPts
    [xyShift, errIm] = MatchTemplate(imTemplates{p,1}, imTemplates{p,2}, imTemplates{p,3}, imFrame, xyGuess(:,p), pad, padSearch );
    if abs( xyShift(1) ) > padEdge || abs( xyShift(2) ) > padEdge
        [xyShift, errIm] = MatchTemplate(imTemplates{p,1}, imTemplates{p,2}, imTemplates{p,3}, imFrame, xyGuess(:,p), pad, padSearch+ 10 );
        if abs(xyShift(1)) > padEdge + 10 || abs(xyShift(2)) > padEdge + 10
            fprintf('Warning: fell out of image %0.0f\n', p);
        end
        if abs( xyShift(1) ) > padEdge || abs( xyShift(2) ) > padEdge
            bOutOfBds = true;
        end
    end
    err = err + errIm;
    xyAdjust(1,p) = xyAdjust(1,p) + xyShift(1);
    xyAdjust(2,p) = xyAdjust(2,p) + xyShift(2);
end

err = ( err / nPts );
end

