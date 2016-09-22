function [ xyShift, err ] = MatchTemplate( imSrc, rectSrc, srcPts, imNext, nextPts, pad, padSearch )
%MatchTemplate Match the template cutout to the other image
%  imSrc: template image
% rectSrc: Where in the original source image the template came from
%             Just need for drawing
% srcPts: Where the points are in the template
%             Just need for drawing
% imNext: Image to search in
% nextPts: Location of points in the next image (can be a guess)
% pad: How much the template image is padded by
% padSearch: How much to add to the box around the points in the search
% image
%    Bigger means more to search for (make bigger if dots moving fast) but
%    also increases computation time

if ~exist('padSearch', 'var')
    padSearch = 20;
end

% Cutout the search image from the full image
% Get a bit bigger piece of the next image
%  Assumes won't move more than padSearch pixs
[imDest, rectDest, destPts] = ClipImageToPoints( imNext, nextPts, padSearch + pad );

% Convert to gray scale if it's not already
if length( size( imDest ) ) == 3
    imDest = rgb2gray( imDest );
end

% If the image template is small use brute force, otherwise, use fancy
% imregister. Which doesn't work for small templates
if size(imSrc,1) < 16 || size(imSrc,2) < 16
    [h, ~,I,J]=im_reg_MI(imSrc, imDest, 0, 1 );
    err = min(min(squeeze(h))) / 255.0;
else
    % Parameters for match
    %  I don't adjust these very well
    [opt, metric] = imregconfig('multimodal');
    opt.InitialRadius = 0.009;
    opt.GrowthFactor = 1.01;
    imRes = imregister( imSrc, imDest, 'translation', opt, metric );
    
    % Idiot imregister doesn't return transformation
    % So look for first non-black pixel
    I = find( imRes(:, round(size(imRes,2) / 2)) ~=0, 1 );
    k = 1;
    while isempty(I) && k < size(imRes,2)
        I = find( imRes(:, k) ~=0, 1 );
        k = k + 1;
    end
    J = find( imRes(round( size(imRes,1) / 2 ),:) ~= 0, 1 );
    k = 1;
    while isempty(J) && k < size(imRes,2)
        J = find( imRes(:, k) ~=0, 1 );
        k = k + 1;
    end

    % How good of a match?
    err = mean( mean( abs(imSrc - imDest( I:I+size(imSrc,1)-1,J:J+size(imSrc,2)-1 )) ) ) / 255.0;
end



% Shift - note, only works if no clipping in ClipImageToPoints
xyShift = [J - padSearch - 1; I - padSearch - 1];

bShow = false; %size(imSrc,1) < 16;
if bShow
    figure(2);
    clf
    
    nRows = 2;
    nCols = 3;
    
    xLeft = rectSrc(1);
    xLeft2 = rectDest(1);
    yBot = rectSrc(2);
    yBot2 = rectDest(2);

    subplot(nRows, nCols,1);
    imshow( imSrc );
    hold on
    plot( [xLeft, xLeft + size(imSrc,2)], [yBot, yBot +  + size(imSrc,1)], '-g', 'LineWidth', 2);
    title('Previous frame');
    
    subplot(nRows, nCols,nCols+1);
    imshow( imNext );
    hold on
    plot( [xLeft2, xLeft2 + size(imDest,2)], [yBot2, yBot2 +  + size(imDest,1)], '-g', 'LineWidth', 2);
    title('Next frame');
    
    subplot(nRows, nCols, 2);
    imshow( imSrc );
    hold on;
    plot( srcPts(1,:), srcPts(2,:), '+g');
    title('Previous crop');
    
    subplot(nRows, nCols, nCols+2);
    imshow( imDest );
    hold on;
    plot( destPts(1,:), destPts(2,:), '+g');
    plot( destPts(1,:) + xyShift(1), destPts(2,:) + xyShift(2), '+r');
    title('Next crop');

    subplot( nRows, nCols, 3 );
    imDestClip = imDest(I:I+size(imSrc,1), J:J+size(imSrc,2));
    %imDestClip = imcrop( imDest, [ J, I, size(imSrc,2), size(imSrc,1) ] );
    imshowpair( imSrc, imDestClip );
    title('Alignment');
    
    subplot( nRows, nCols, nCols + 3);
    ShowCloseupWithPts( imNext, [nextPts(1,:) + xyShift(1); nextPts(2,:) + xyShift(2)] );
    title('Shift on next');
end

end

