function [h, theta,I,J]=im_reg_MI(image1, image2, angle, step);
% function [h,im_matched, theta,I,J]=im_reg_MI(image1, image2, angle, step);
%
% function for registering image 1 and image 2 using Mutual Information
%
% Function for those who don't have access to Image Processing toolbox
% rotate_image.m function by Ohad Gal is used
% For users having access to IP toolbox can download image_registr_MI.m
% which uses IMROTATE function and has an option to crop the image to save
% computation time
%
% Mutual Information files are taken from:
% http://www.flash.net/~strider2/matlab.htm
% 
% Rigid registration - only translation and rotation are corrected
% For each angle of rotation set of translation is checked
% Can use only for translation by setting angle=0
%
% INPUT:
% Larger IMAGE2 is registered to smaller IMAGE1
%
% angle - vector of angles to check, for example 
% angle=[-30:2:30] or 
% angle=15;
%
% step - how many pixels to shift in x and y directions for translation check
% 
% OUTPUT:
% im_matched - matched part of image 2
% h - MI for the best theta
% theta - best angle of rotation
% I and J - coordinates of left top corner of matched area within large IMAGE2
%
% MIGHT BE REALLY SLOW FOR A LOT OF ANGLES AND SMALL STEPS!
% TOO LARGE STEPS CAN CAUSE FALSE REGISTRATION
% I RUN IT OVERNIGHT WITH SMALL STEPS TO GET THE BEST POSSIBLE MATCH
% 
% example:
%
% [h,im_matched, theta,I,J]=im_reg_MI(image1, image2, [-10:5:10], 5);
%
% just translation:
%[ h,im_matched, theta,I,J]=im_reg_MI(image1, image2, 0, 1);
%
% written by K.Artyushkova
% 02_2004

% Kateryna Artyushkova
% Postdoctoral Scientist
% Department of Chemical and Nuclear Engineering
% The University of New Mexico
% (505) 277-0750
% kartyush@unm.edu 

[m,n]=size(image1);
[p,q]=size(image2); 
[a,b]=size(angle);
im1=round(image1); 

for k=1:b
    J = imrotate(image2, angle(k)); %rotated cropped IMAGE2
    image21=round(J);
    [m1,n1]=size(image21);
    for i=1:step:(m1-m)
        for j=1:step:(n1-n)
                im2=image21(i:(i+m-1),j:(j+n-1)); % selecting part of IMAGE2 matching the size of IMAHE1
                %im2=round(im2); 
                h(k,i,j)=mean( mean( abs(im1 - im2) ) );
                %h(k,i,j)=MI2(im1,im2); % calculating MI
            end
        end
    end
  

[~, b] = min(h(:));% finding the max of MI and indecises
[K,I,J] = ind2sub(size(h),b);

theta=angle(K);

bPlot = false;
if bPlot
    im_rot = imrotate(image2, theta);
    im_matched=im_rot(I:(I+m-1),J:(J+n-1));
    
    figure(4);
    subplot(2,2,1)
    imshow(image2)
    title('Original image 2')
    subplot(2,2,2)
    imshow(im_rot)
    title('Rotated image 2')
    colormap (gray)

    subplot(2,2,3)
    imshow(image1)
    title('Original image 1')
    subplot(2,2,4)
    imshow(im_matched)
    title('Matched image 2')
    colormap (gray)
end;