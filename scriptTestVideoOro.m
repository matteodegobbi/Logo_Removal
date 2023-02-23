t=[1,5,10,20,30];
logoImage = im2double(rgb2gray(imread("cameo\logo.png")));%legge logo
vidObj = VideoReader("risultati\cameo.mp4");
for j=t
    vidObj = VideoReader("risultati\cameo.mp4");
    errorcounter=0;%conta il numero di frame dove non viene trovato il logo
%legge video

videoCensurato=zeros(vidObj.Height,vidObj.Width,vidObj.NumFrames);
f=figure('visible','off');%figure non visible per velocizzare la elaborazione
i=1;
while hasFrame(vidObj)%applica la censura frame per frame
    frame = readFrame(vidObj);
    frame=im2double(rgb2gray(frame));
    [videoCensurato(:,:,i),error]=SIFT_frame_funzione(logoImage,frame,j);
    errorcounter=errorcounter+error;
    disp(""+i+'/'+vidObj.NumFrames);%printa il progresso corrente
    i=i+1;
end
video = VideoWriter(strcat('proveVideo/cameoM',num2str(j),'err',num2str(errorcounter),'proj.avi')); %crea l'oggetto video
video.FrameRate=vidObj.FrameRate;
open(video); %apre il file video
for i=1:vidObj.NumFrames
    writeVideo(video,videoCensurato(:,:,i));%scrive sul file
end
close(video);%chiude il file
disp(errorcounter);
end