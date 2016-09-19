function [ xyShift ] = MatchAll( imPrev, regPrev, imNext )
%MatchAll Find the xy shift that best takes the region around the previous
%points to the new image
%   Basically a brain-dead try all possible

xLeft = round( min( regPrev.Location(:,1) ) - 5 );
xRight = round( max( regPrev.Location(:,1) ) + 5 );

yTop = round( min( regPrev.Location(:,2) ) - 5 );
yBot = round( max( regPrev.Location(:,2) ) + 5 );

[xyShift] = TemplateMatch( imPrev( xLeft:xRight yTop:yBot,:), imNext );
end

