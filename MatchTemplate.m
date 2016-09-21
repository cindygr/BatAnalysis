function [ xyShift ] = MatchTemplate( imSrc, rectSrc, srcPts, imNext, nextPts, pad, padSearch )
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here

if ~exist('padSearch', 'var')
    padSearch = 20;
end

[imDest, rectDest, destPts] = ClipImageToPoints( imNext, nextPts, padSearch + pad );

% Get a bit bigger piece of the next image
%  Assumes won't move more than 20 pixs
imDest = rgb2gray( imDest );

    % Parameters for match
[opt, metric] = imregconfig('multimodal');
if size(imSrc,1) < 16 || size(imSrc,2) < 16
    [~,~, ~,I,J]=im_reg_MI(imSrc, imDest, 0, 1 );
else
    opt.InitialRadius = opt.InitialRadius * 0.1;
    imRes = imregister( imSrc, imDest, 'translation', opt, metric );
    
    % Idiot imregister doesn't return transformation
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
    % Too lazy to correct above code
    A = I;
    I = J;
    J = A;
end

% Shift - note, only works if no clipping in ClipImageToPoints
xyShift = [I - padSearch - 1; J - padSearch - 1];

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

