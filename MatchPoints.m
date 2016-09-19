function [ ptIndex ] = MatchPoints( ptsTrack, regions )
%MatchPoints Match the x,y locations to the regions
%   Just find the closest points

nPts = size(ptsTrack, 2);
nRegs = regions.Count;

dists = zeros( nPts, nRegs );

% Could probably use pixel list too...
for p = 1:nPts
    for r = 1:nRegs
        dists(p, r) = (ptsTrack(1,p) - regions.Location(r,1)).^2 + ...
                      (ptsTrack(2,p) - regions.Location(r,2)).^2;
    end
end

ptIndex = zeros( nPts, 1 );
for k = 1:nPts
    % Find the closest match between a track point and a region
    [~,I] = min(dists(:));
    [I_row, I_col] = ind2sub(size(dists),I);
    % Put that match in
    %dists(I_row, I_col)
    ptIndex(I_row) = I_col;
    
    %plot( ptsTrack(1,I_row), ptsTrack(2,I_row), '-Or');
    %plot( [ptsTrack(1,I_row) regions.Location(I_col,1)], [ptsTrack(2,I_row) regions.Location(I_col,2)], '-Xg');
    
    % Make it so we don't pick this point or region again
    dists( :, I_col ) = 1e30;
    dists( I_row, : ) = 1e30;
end

end