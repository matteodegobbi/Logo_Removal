clear
%ATTENZIONE: sostituire con l'IP del proprio computer
S = tcpserver("192.168.1.55",4316,"ByteOrder","little-endian");
S.ConnectionChangedFcn = @callBackConnesso;
global dataread;%variabile globale conterrà l'immagine inviata da android in array di byte(uint8 in matlab)


function callBackConnesso(S,~)
global dataread;
dataread=[];
if S.Connected   
    disp(['Connected with Client with IP: ',S.ClientAddress,' at port number ',num2str(S.ClientPort)]);
    continua=true;
    %ciclo che legge byte dal socket finché non incontra la ending sequence
    while continua
        if S.NumBytesAvailable>0
            currentBytes=[S.read(S.NumBytesAvailable,"uint8")];
            dataread=[dataread,currentBytes];
            continua=~checkFineStream(dataread);
        end
    end
    disp("finito di leggere Immagine")

    %scrivo l'immagine su un file png usando Java
    outputFile=javaObject("java.io.File","outputFile.png");
    outputStream=javaObject("java.io.FileOutputStream",outputFile);
    javaMethod("write",outputStream,dataread)
    javaMethod("close",outputStream)
    %individuo e rimuovo il logo con SIFT
    logoImage = im2double(rgb2gray(imread('pokemon/logo.png')));
    sceneImage=im2double(rgb2gray(imread("outputFile.png")));
    immagineCensurata=SIFT_frame_funzione(logoImage,sceneImage);
    imwrite(immagineCensurata,"censurataOutput.png","png");
    
else
    disp('Client disconnected')
end
end
%Serve a controllare la ending sequence dell'invio immagine ovvero 32 byte di NULL
function fine=checkFineStream(data)
fine = true;
dimensioni=size(data);
lunghezza=dimensioni(2);
for i=0:31
    fine=and(fine,data(lunghezza-i)==0);
end
    
end
