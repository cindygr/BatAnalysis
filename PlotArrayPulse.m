function [  ] = PlotArrayPulse(whichPulse, peak, peaktime, resid, g )
%PlotArrayPulse Plot the pulse's data across an array

% Center 0.097321 
% Center 0.000000 
% Center 3.751338 
% Center 0.000343 
% Center 0.000000 
% Center -0.000000 
% Scale 0.031701 
% Scale 0.251028 
% Scale 0.147903 
% Scale 0.000134 
% Scale 0.029775 
% Scale 0.561319 

plot( 4 + (peak(whichPulse,1:8) - mean(peak(whichPulse,1:8))) / 0.029775, '-k', 'LineWidth', 2 );
hold on;
plot( 2 + (peaktime(whichPulse,1:8) - mean(peaktime(whichPulse,1:8))) / 0.561319, '--b', 'LineWidth', 2);
plot( 0 + (resid(whichPulse,1:8) - 0.000343) / 0.000134, '--r', 'LineWidth', 2);

vars = zeros(8, 3);
for m = 1:8
    vars(m,1) = g{whichPulse,m}.a1 - 0.1;
    vars(m,2) = g{whichPulse,m}.b1;
    vars(m,3) = g{whichPulse,m}.c1 - 3.75;
end
vars(:,2) = mean( vars(:,2) ) - vars(:,2);

plot( -2 + vars(:,1) / 0.03, '--X', 'color', [0 1 0], 'LineWidth', 2 );
plot( -4.0  + vars(:,2) / 0.25, '-.o', 'color', [0 0.8 0], 'LineWidth', 2 );
plot( -6.0 + vars(:,3) / 0.15, '-*', 'color', [0 0.6 0], 'LineWidth', 2 );

xlabel('Microphone');
ylabel('Intensity, Time (ms), err');
title('Microphone distribution');


end

