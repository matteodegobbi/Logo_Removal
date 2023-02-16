function [J,error]=SIFT_frame_funzione(logoImage,sceneImage)
error=0;

logoPoints = detectSIFTFeatures(logoImage);
scenePoints = detectSIFTFeatures(sceneImage);

[logoFeatures, logoPoints] = extractFeatures(logoImage, logoPoints);
[sceneFeatures, scenePoints] = extractFeatures(sceneImage, scenePoints);

logoPairs = matchFeatures(logoFeatures, sceneFeatures,"MatchThreshold",10);

matchedLogoPoints = logoPoints(logoPairs(:, 1), :);
matchedScenePoints = scenePoints(logoPairs(:, 2), :);

try
    [tform, inlierIdx] = estgeotform2d(matchedLogoPoints, matchedScenePoints, 'affine');
    inlierLogoPoints   = matchedLogoPoints(inlierIdx, :);
    inlierScenePoints = matchedScenePoints(inlierIdx, :);



    logoPolygon = [1, 1;...                           % top-left
        size(logoImage, 2), 1;...                 % top-right
        size(logoImage, 2), size(logoImage, 1);... % bottom-right
        1, size(logoImage, 1);...                 % bottom-left
        1, 1];                   % top-left again to close the polygon

    newLogoPolygon = transformPointsForward(tform, logoPolygon);

    %figure;
    imshow(sceneImage);

    roi = drawpolygon(gca,'Position',[newLogoPolygon(:,1),newLogoPolygon(:,2)]);


    mask = createMask(roi);



    J = regionfill(sceneImage,mask);
catch exception
    disp(exception)
    
    J=sceneImage;
    error=1;
end



end