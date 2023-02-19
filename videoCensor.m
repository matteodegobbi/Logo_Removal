function videoCensor(percorsoLogo,percorsoVideo)
%prende in input il percorso del logo e il percorso del video e censura
%frame per frame i loghi presenti nel video

errorcounter=0;%conta il numero di frame dove non viene trovato il logo
logoImage = im2double(rgb2gray(imread(percorsoLogo)));%legge logo
vidObj = VideoReader(percorsoVideo);%legge video

videoCensurato=zeros(vidObj.Height,vidObj.Width,vidObj.NumFrames);
f=figure('visible','off');%figure non visible per velocizzare la elaborazione
i=1;
while hasFrame(vidObj)%applica la censura frame per frame
    frame = readFrame(vidObj);
    frame=im2double(rgb2gray(frame));
    [videoCensurato(:,:,i),error]=SIFT_frame_funzione(logoImage,frame);
    errorcounter=errorcounter+error;
    disp(""+i+'/'+vidObj.NumFrames);%printa il progresso corrente
    i=i+1;
end
video = VideoWriter('outputVideo.avi'); %crea l'oggetto video
video.FrameRate=vidObj.FrameRate;
open(video); %apre il file video
for i=1:vidObj.NumFrames
    writeVideo(video,videoCensurato(:,:,i));%scrive sul file
end
close(video);%chiude il file
disp(errorcounter);
end