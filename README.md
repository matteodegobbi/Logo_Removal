# Logo_Removal
Sift è un algoritmo di estrazione di feature da un'immagine che prende in input un immagine
e restituisce un sottoinsieme di punti rappresentativi dell'immagine con collegata una descrizione di punti
che poi verrà confrontato con l'insieme di feature del'altra immagine 
//TODO metti a posto sta parte precedente
## Scale Space (invarianza spaziale e eliminazione rumore)
SIFT prima di tutto costruisce lo scale space 
crea N versioni scalate dell'immagine originale (in modo da ottenere scale-invariance SI) da ognuna 
di queste N versioni crea altre M immagini con livelli diversi di gaussian-blur (per cercare di rendere l'algoritmo resistente al rumore)
Alla fine della procedura avremo NxM immagini ogni livello di scalatura viene chiamato ottava e 
contiene M versioni con blur diversi 
//TODO inserisci immagine ottava oppure/e apri MATLAB
## Difference of Gaussian
Poi SIFT ottiene un nuovo set di immagini per ogni ottava sottranedo dalle immagini poco blurrate
quelle molto blurrate mantenedo quindi le componenti ad alta frequenza e attenuando quelle a bassa
frequenza
Su questo set chiamato DOG difference of gaussians per ogni immagine si trovano gli estremi locali
Per farlo si compara ogni pixel con gli 8 che lo circondano nella immagine e con i 9 corrispondenti 
nell'ottava precedente e i 9 corrispondenti nell'ottava successiva se il pixel è > di questi altri 26 (o < di tutti) allora viene preso
come feature.
### approx del Laplace 
la DOG approssima l'operatore laplaciano con la differenza che non deve essere normalizzato per la scala
//TODO aggiungi reference lindeberg
##Rimozione feature a contrasto basso o lungo bordi
Con questa procedura otteniamo troppi feature points dobbiamo eliminare le feature spurie date da punti a basso contrasto o
bordi che non sono dei veri estremi locali. Prima di tutto si rimuovono i punti in aree a basso contrasto utilizzando un threshold al contrasto
minimo sotto quale 
