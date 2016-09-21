function [ xyShift ] = MatchAll( imPrev, prevPts, imNext, nextPts, pad, padSearch )
%MatchAll Find the xy shift that best takes the region around the previous
%points to the new image
%   Basically a brain-dead try all possible

if ~exist('pad', 'var')
    pad = 5;
end
if ~exist('padSearch', 'var')
    padSearch = 20;
end
if ~exist('nextPts', 'var')
    prevPts = nextPts;
end

[imSrc, rectSrc, srcPts] = ClipImageToPoints( imPrev, prevPts, pad );
imSrc = rgb2gray(imSrc);

xyShift = MatchTemplate( imSrc, rectSrc, srcPts, imNext, nextPts, pad, padSearch );

end
