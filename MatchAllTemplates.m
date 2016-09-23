function [ xyAdjust, err, bOutOfBds ] = MatchAllTemplates( imTemplates, imFrame, xyGuess, xyAdjustPrev, pad, padSearch )
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
    % Shift the template
    [xyShift, errIm] = MatchTemplate(imTemplates{p,1}, imTemplates{p,2}, imTemplates{p,3}, imFrame, xyGuess(:,p), pad, padSearch, false );
    
    % See if the template was shifted to the edge of the image
    if abs( xyShift(1) ) > padEdge || abs( xyShift(2) ) > padEdge
        % Try adding in a bit of the adjust from last time
        xyAdjust(:,p) = 0.5 * xyGuess(:,p) + 0.5 * xyAdjustPrev(:,p);
        [xyShift, errIm] = MatchTemplate(imTemplates{p,1}, imTemplates{p,2}, imTemplates{p,3}, ...
            imFrame, xyAdjust(:,p), pad, padSearch, true );
        
        % *still* fell out of the image

        % don't go to edge - but flag this is a bad match
        if abs(xyShift(1)) > padEdge 
            fprintf('\nWarning: fell out of image pt %0.0f\n', p);
            bOutOfBds = true;
            xyShift(1) = 0;
        end
        if abs(xyShift(2)) > padEdge
            fprintf('\nWarning: fell out of image pt %0.0f\n', p);
            bOutOfBds = true;
            xyShift(2) = 0;
        end
    end
    
    % Error for this match
    err = err + errIm;
    
    % Shift the points by the template shift
    xyAdjust(1,p) = xyAdjust(1,p) + xyShift(1);
    xyAdjust(2,p) = xyAdjust(2,p) + xyShift(2);
end

err = ( err / nPts );
end

