function [ ptIndex ] = MatchFeaturePoints( imPrev, ptsOrig, imNext, regsNew )
%MatchFeaturePoints Use built-in matching to match features
%   Detailed explanation goes here

%[f1, vpts1] = extractFeatures( rgb2gray(imPrev), ptsOrig' );
%[f2, vpts2] = extractFeatures( rgb2gray(imNext), [regsNew.Location(:,1) regsNew.Location(:,2)] );

%[ptIndex, metric] = matchFeatures( f1, f2, 'unique', true );
[ptIndex, ~] = MatchPoints( imPrev, ptsOrig, imNext, regsNew );

% if ptIndex ~= ptIndexPts
%     fprintf('bad match\n');
% end

end

