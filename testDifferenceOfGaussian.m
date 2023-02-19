clear 
close all
cameraman=im2double(imread("cameraman.tif"));
figure(1);
subplot(2,2,1);
imshow(cameraman);
title("originale");

c1=imgaussfilt(cameraman,1);
c2=imgaussfilt(cameraman,5);
subplot(2,2,2);
imshow(c1);
title("blur 1 volta");

subplot(2,2,3);
imshow(c2);
title("blur 2 volte");

cDOG=c1-c2;
subplot(2,2,4);
imshow(cDOG);
title("difference of gaussians");
%notare come DOG è una approx di laplace (ma invariante alla scala)
figure(2)
fLaplace=fspecial("laplacian");
c3=imfilter(cameraman,fLaplace);
imshow(c3)
title("Laplacian")
