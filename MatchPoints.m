function [ ptIndex, distToReg ] = MatchPoints( imPrev, ptsTrack, imNext, regions )
%MatchPoints Match the x,y locations to the regions
%   Just find the closest points

nPts = size(ptsTrack, 2);
nRegs = regions.Count;

dists = zeros( nPts, nRegs );
distToReg = zeros( nPts, 1 );

% Could probably use pixel list too...
ptIndex = zeros( nPts, 1 );
for p = 1:nPts
%     xyShift = MatchAll(imPrev, ptsTrack(:,p), imNext, ptsTrack(:,p), 5, 10 );
%     ptsTrack(1,p) = ptsTrack(1,p) + xyShift(1);
%     ptsTrack(2,p) = ptsTrack(2,p) + xyShift(1);
    for r = 1:nRegs
        dists(p, r) = (ptsTrack(1,p) - regions.Location(r,1)).^2 + ...
                      (ptsTrack(2,p) - regions.Location(r,2)).^2;
    end
    [~, ptIndex(p)] = min(dists(p,:));
end

for k = 1:nPts
    % Find the closest match between a track point and a region
    [dM,I] = min(dists(:));
    [I_row, I_col] = ind2sub(size(dists),I);
    % Put that match in
    %dists(I_row, I_col)
    distToReg(I_row) = dM;
    if (dM < 300)
        ptIndex(I_row) = I_col;
    else
        fprintf('Bad match\n');
    end
    
    plot( ptsTrack(1,I_row), ptsTrack(2,I_row), '-Or');
    plot( [ptsTrack(1,I_row) regions.Location(I_col,1)], [ptsTrack(2,I_row) regions.Location(I_col,2)], '-Xg');
    
    % Make it so we don't pick this point or region again
    dists( :, I_col ) = 1e30;
    dists( I_row, : ) = 1e30;
end

end