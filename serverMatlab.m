clear
S = tcpserver("192.168.1.55",4316,"ByteOrder","little-endian");

S.ConnectionChangedFcn = @callBackConnesso;
dataread=0;
function callBackConnesso(S,~)
if S.Connected
    disp('Connection OK!');
    disp(['Connected with Client with IP: ',S.ClientAddress,...
        ' at port number ',num2str(S.ClientPort)]);

    write(S,uint8(double("risposta")));
    

else
    disp('Client disconnected')
end
end
