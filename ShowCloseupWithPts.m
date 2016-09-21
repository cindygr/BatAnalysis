function [  ] = ShowCloseupWithPts( im, regs )
%ShowCloseupWithPts Clip the image to the points and show
%   
pad = 5;
if ( size(regs,1) > 1 )
    [imCloseup, ~, pts] = ClipImageToPoints( im, regs, 5 );
else
    [imCloseup, ~, pts] = ClipImageToRegion( im, regs, 5 );
end
imshow( imCloseup );
hold on;

xLeft = round( min( pts(1,:) ) ) - pad;
xRight = round( max(pts(1,:) ) ) + pad;

yBot = round( min( pts(2,:) ) ) - pad;
yTop = round( max( pts(2,:) ) ) + pad;

for r = 1:size(pts,2)
    if size(regs,1) == 1
        markerSize = 40 * size( regs.PixelList(r), 1 ) / 100;
    else
        markerSize = 20;
    end
    u = ( pts(1,r) - xLeft ) / (xRight - xLeft );
    v = ( pts(2,r) - yBot ) / (yTop - yBot );
    xLoc = pts(1,r);
    yLoc = pts(2,r);
    plot( xLoc, yLoc, 'o', 'MarkerSize', markerSize, 'Color', [u, 0.5, v], 'LineWidth', 2 );
    plot( xLoc, yLoc, '+', 'MarkerSize', markerSize, 'Color', [u, 0.5, v], 'LineWidth', 2 );
%    text( xLoc, yLoc, num2str(r) ); % I have no idea why this isn't
%    working
end
end

