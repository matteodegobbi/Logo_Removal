clear
close all
logoImage = im2double(rgb2gray(imread('cameo/logo.png')));
% figure;
% imshow(logoImage);
% title('Image of a Box');

sceneImage = im2double(rgb2gray(imread('cameo/ciobar2.jpg')));


% logoImage=imgaussfilt(logoImage,10);
% sceneImage=imgaussfilt(sceneImage,10);

% figure;
% imshow(sceneImage);
% title('Image of a Cluttered Scene');

logoPoints = detectSIFTFeatures(logoImage);
scenePoints = detectSIFTFeatures(sceneImage);

figure;
imshow(logoImage);
title('100 Strongest Feature Points from Logo Image');
hold on;
plot(selectStrongest(logoPoints, 100));

figure;
imshow(sceneImage);
title('300 Strongest Feature Points from Scene Image');
hold on;
plot(selectStrongest(scenePoints, 300));

[logoFeatures, logoPoints] = extractFeatures(logoImage, logoPoints);
[sceneFeatures, scenePoints] = extractFeatures(sceneImage, scenePoints);

logoPairs = matchFeatures(logoFeatures, sceneFeatures,"MatchThreshold",10);

matchedLogoPoints = logoPoints(logoPairs(:, 1), :);
matchedScenePoints = scenePoints(logoPairs(:, 2), :);
figure;
showMatchedFeatures(logoImage, sceneImage, matchedLogoPoints, ...
    matchedScenePoints, 'montage');
title('supposedly Matched Points (Including Outliers)');


[tform, inlierIdx] = estgeotform2d(matchedLogoPoints, matchedScenePoints, 'affine');
inlierLogoPoints   = matchedLogoPoints(inlierIdx, :);
inlierScenePoints = matchedScenePoints(inlierIdx, :);

figure;
showMatchedFeatures(logoImage, sceneImage, inlierLogoPoints, ...
    inlierScenePoints, 'montage');
title('Matched Points (Inliers Only)');

logoPolygon = [1, 1;...                           % top-left
        size(logoImage, 2), 1;...                 % top-right
        size(logoImage, 2), size(logoImage, 1);... % bottom-right
        1, size(logoImage, 1);...                 % bottom-left
        1, 1];                   % top-left again to close the polygon

newLogoPolygon = transformPointsForward(tform, logoPolygon);


figure;
imshow(sceneImage);
%hold on;
roi = drawpolygon(gca,'Position',[newLogoPolygon(:,1),newLogoPolygon(:,2)]);
%line(newLogoPolygon(:, 1), newLogoPolygon(:, 2), Color='y');
title('Detected Box');

mask = createMask(roi);
imshow(mask)
figure


J = regionfill(sceneImage,mask);

imshow([sceneImage,J]);