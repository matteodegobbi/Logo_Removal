% array=javaArray("java.lang.Byte",10);
% javaMethod("decodeByteArray",java.util.Date,array,0,10)
% File outputFile = tempFolder.newFile("outputFile.jpg");
% try (FileOutputStream outputStream = new FileOutputStream(outputFile)) {
%     outputStream.write(dataForWriting);
% }

%dataread=read(S,S.NumBytesAvailable);
outputFile=javaObject("java.io.File","outputFile.png");
outputStream=javaObject("java.io.FileOutputStream",outputFile);
javaMethod("write",outputStream,dataread)
