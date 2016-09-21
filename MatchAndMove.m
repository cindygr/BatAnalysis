function [ regNextMatched, ptsTrackMove ] = MatchAndMove( imPrev, ptsTrack, imNext, regNextPts )
%MatchAndMove Move the points into the next image and match
%   imPrev:  previous frame image
%   ptsTrack is the original clicked points, translated
%   imNext: next image
%   regNextPts all the MSER regions in the current frame
%
% Returns a list (in order) of which points match
% Also shifts the points

% Shift entire image clip containing points to new image
xyShift = MatchAll( imPrev, ptsTrack, imNext, ptsTrack );

% Points
% shift the points by the amount found
ptsTrackMove(1,:) = ptsTrack(1,:) + xyShift(1);
ptsTrackMove(2,:) = ptsTrack(2,:) + xyShift(2);

% Now re-match points
ptsIndex = MatchFeaturePoints( imPrev, ptsTrackMove, imNext, regNextPts );
% if bUseFeature
%     ptsIndex = MatchFeaturePoints( regPrev, ptsTrackMove, regNextPts );
% else
%     ptsIndex = MatchPoints( ptsTrackMove, regNextPts );
% end

regNextMatched = regNextPts( ptsIndex );
end

