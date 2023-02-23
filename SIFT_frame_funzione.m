function [J,error]=SIFT_frame_funzione(logoImage,sceneImage,Match)
%questa funzione prende come input le immagini del logo e la foto da censurare 
%e cancella il logo dall'immagine

error=0;%varrà 1 se SIFT  non trova loghi

%estrazione feature
logoPoints = detectSIFTFeatures(logoImage);
scenePoints = detectSIFTFeatures(sceneImage);

[logoFeatures, logoPoints] = extractFeatures(logoImage, logoPoints);
[sceneFeatures, scenePoints] = extractFeatures(sceneImage, scenePoints);

%matching delle feature con distanza euclidea tra i vettori di feature
logoPairs = matchFeatures(logoFeatures, sceneFeatures,"MatchThreshold",Match);

matchedLogoPoints = logoPoints(logoPairs(:, 1), :);
matchedScenePoints = scenePoints(logoPairs(:, 2), :);

try
    %stima la trasformazione che porta dai keyPoints del logo a quelli
    %dell'immagine
    [tform, inlierIdx] = estgeotform2d(matchedLogoPoints, matchedScenePoints, 'affine');
    inlierLogoPoints   = matchedLogoPoints(inlierIdx, :);
    inlierScenePoints = matchedScenePoints(inlierIdx, :);
    
    
    
    logoPolygon = [1, 1;...                           % vertice sx-su
        size(logoImage, 2), 1;...                 % vertice dx-su
        size(logoImage, 2), size(logoImage, 1);... % vertice dx-giu
        1, size(logoImage, 1);...                 % vertice sx-giu
        1, 1];                   % chiude la spezzata
    
    %trasforma i vertici del logo nei punti che circondano il logo nella
    %foto
    newLogoPolygon = transformPointsForward(tform, logoPolygon);

    %figure;
    imshow(sceneImage);
    
    %crea una region of interest (ROI) con la forma del poligono che copre il
    %logo
    roi = drawpolygon(gca,'Position',[newLogoPolygon(:,1),newLogoPolygon(:,2)]);

    
    %crea una maschera da applicare all'immagine con 1 nella ROI e 0 al di
    %fuori
    mask = createMask(roi);


    %esegue una interpolazione nella zona definita dalla maschera
    %corrispondente alla ROI
    J = regionfill(sceneImage,mask);
catch exception
    %se SIFT non trova il logo l'immagine restituita sarà uguale alla
    %originale
    disp(exception)
    J=sceneImage;
    error=1;
end



end