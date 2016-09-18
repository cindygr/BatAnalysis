nRows = 6;
nCols = 6;


% Read in the 3D point data
dataPts3D = zeros(9, 3, 5);
dataPtsMat = cell(9,1);
for k = 1:9
    dataPtsMat{k} = load( sprintf('9-15bat/position_point_%0.0f.mat',k) );
end
dataPts3D(1,:,:) = dataPtsMat{1}.PT_1;
dataPts3D(2,:,:) = dataPtsMat{2}.PT_2;
dataPts3D(3,:,:) = dataPtsMat{3}.PT_3;
dataPts3D(4,:,:) = dataPtsMat{4}.PT_4;
dataPts3D(5,:,:) = dataPtsMat{5}.PT_5;
dataPts3D(6,:,:) = dataPtsMat{6}.PT_6;
dataPts3D(7,:,:) = dataPtsMat{7}.PT_7;
dataPts3D(8,:,:) = dataPtsMat{8}.PT_8;
dataPts3D(9,:,:) = dataPtsMat{9}.PT_9;

% figList = cell(35,1);
% for k=1:35
%     figList{k} = openfig( sprintf('9-15bat/5/9-10_%0.0f.fig',k) )
% end
clf
for k = 1:9
   plot3( squeeze(dataPts3D(k,1,:)), squeeze(dataPts3D(k,2,:)), squeeze(dataPts3D(k,3,:)) );
   hold on;
end
