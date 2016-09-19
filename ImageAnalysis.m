%% See about automatically fitting the dots on the bat's face
%

dataDir = '9-15bat/5/';
whichPulse = 1;

if ~exist('imRaw', 'var')
    imRaw = ReadFrames( dataDir, whichPulse );
end

nImages = size( imRaw, 1);


% 
% imRaw{1,1} = imread( '9-15bat/1/left_1/1_002395.jpg' );
% imRaw{2,1} = imread( '9-15bat/1/right_1/1_002392.jpg' );
% 
% imRaw{3,1} = imread( '9-15bat/5/left_1/1_002396.jpg' );
% imRaw{4,1} = imread( '9-15bat/5/right_1/1_002398.jpg' );
% 

if ~exist('imClip', 'var')
    imClip = cell( nImages,2);
    figure(1);
    clf;
    [imClip{1,1}, imClip{1,2}] = imcrop( imRaw{1,1} );
    [imClip{end,1}, imClip{end,2}] = imcrop( imRaw{end,1} );
    for k = 2:nImages-1
        t = (k-1) / nImages; 
        imClip{k,2} = round( (1-t) * imClip{1,2} + t * imClip{end,2} );
        [imClip{k,1}] = imcrop( imRaw{k,1}, imClip{k,2} );
    end    
end

if ~exist('imT', 'var')
    imT = cell( nImages,3);
    for k = 1:nImages
        imTh = ThresholdImage( imClip{k,1} );
        regs = detectMSERFeatures(rgb2gray(imClip{k,1}), 'RegionAreaRange', [1, 100]);
        regKeep = zeros( regs.Count ) == 1;
        for r=1:regs.Count
            pixs = regs.PixelList(r);
            pixOverlap = sum( sum( imTh(pixs(:,2), pixs(:,1 ) ) > 0 ) );
            if pixOverlap > 0.5
                regKeep(r) = true;
            end
        end
        imT{k,1} = imTh;
        imT{k,2} = regs;
        imT{k,3} = regs(regKeep);
    end
end

if ~exist('ptsTrack', 'var')
    fig = figure(1);
    clf
    imshow( imClip{1,1} );
    [x,y] = getpts( fig );
    ptsTrack = [ x(1:end-1)'; y(1:end-1)' ];    
end

if ~exist('regTrack', 'var')
    regTrack = cell(nImages, 1);
    ptsIndex = MatchPoints( ptsTrack, imT{1,3} );
    regTrack{1,1} = imT{1,3}(ptsIndex);
    for k = 2:nImages
        ptsIndex = MatchPoints( ptsTrack, imT{k,3} );
        regTrack{k,1} = imT{k,3}(ptsIndex);
    end
end

clf
nRows = 5;
nCols = nImages;
for k = 1:nImages
    subplot(nRows, nCols, k)
    imshow( imRaw{k,1} );

    subplot(nRows, nCols, nCols + k)
    imshow( imClip{k,1} );

    subplot(nRows, nCols, 2*nCols + k)
    imshow( imClip{k,1} );
    hold on;
    plot(imT{k,2});
    
    subplot(nRows, nCols, 3*nCols + k)
    imshow( imT{k,1} );
    hold on;
    plot(imT{k,3} );
    
    subplot(nRows, nCols, 4*nCols + k)
    imshow( imT{k,1} );
    hold on;
    plot(regTrack{k,1} );
end

