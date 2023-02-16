function videoCensor(percorsoLogo,percorsoVideo)
errorcounter=0;
logoImage = im2double(rgb2gray(imread(percorsoLogo)));
vidObj = VideoReader(percorsoVideo);
videoCensurato=zeros(vidObj.Height,vidObj.Width,vidObj.NumFrames);
f=figure('visible','off');
i=1;
while hasFrame(vidObj)
    frame = readFrame(vidObj);
    frame=im2double(rgb2gray(frame));
    [videoCensurato(:,:,i),error]=SIFT_frame_funzione(logoImage,frame);
    errorcounter=errorcounter+error;
    disp(""+i+'/'+vidObj.NumFrames);
    i=i+1;
end
video = VideoWriter('outputVideo.avi'); %create the video object
video.FrameRate=vidObj.FrameRate;
open(video); %open the file for writing
for i=1:vidObj.NumFrames
    writeVideo(video,videoCensurato(:,:,i));
end
close(video);
disp(errorcounter);
end