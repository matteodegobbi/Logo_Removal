# Logo Removal 
## Cos'è SIFT? (Scale Invariant Feature Transform)
SIFT è un algoritmo di estrazione di feature da un'immagine che prende in input un'immagine e restituisce un sottoinsieme di punti rappresentativi dell'immagine (keyPoints) con delle corrispondenti descrizioni dei punti che possono essere utilizzate per trovare corrispodenze tra immagini diverse, SIFT è invariante a cambiamenti di scala e in gran parte anche a rotazioni.

### Scale Space (invarianza spaziale e eliminazione rumore)
SIFT prima di tutto costruisce lo scale space: crea N versioni scalate dell'immagine originale (in modo da ottenere scale-invariance SI) da ognuna di queste N versioni crea altre M immagini con livelli diversi di gaussian-blur. Alla fine della procedura avremo NxM immagini. Ogni livello di scalatura viene chiamato ottava e contiene M versioni con blur diversi

### Difference of Gaussian (DOG)
Poi SIFT ottiene un nuovo set di immagini per ogni ottava sottranedo dalle immagini con poco blur (varianza della gaussiana bassa) quelle con molto blur mantenedo quindi le componenti ad alta frequenza e attenuando quelle a bassa frequenza.

Su questo set chiamato DOG difference of gaussians per ogni immagine si trovano gli estremi locali. Per farlo si compara ogni pixel con gli 8 che lo circondano nella immagine e con i 9 corrispondenti nell'ottava precedente e i 9 corrispondenti nell'ottava successiva se il pixel è > di questi altri 26 (o < di tutti) allora viene preso come feature.

#### Approsimazione del Laplaciano
la DOG approssima l'operatore Laplaciano con la differenza che non deve essere normalizzato per la scala (Laplaciano è scale variant perché le immagini a risoluzione più alta hanno pendenze più basse ovvero valori delle derivate più bassi)
[Feature Detection with Automatic Scale Selection[1]](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=&cad=rja&uact=8&ved=2ahUKEwimn5HDnKL9AhXdVPEDHWv8DBUQgAMoAHoECAQQAw&url=https%3A%2F%2Fscholar.google.it%2Fscholar_url%3Furl%3Dhttps%3A%2F%2Fwww.diva-portal.org%2Fsmash%2Fget%2Fdiva2%3A453064%2FFULLTEXT01.pdf%26hl%3Dit%26sa%3DX%26ei%3DeWvyY53MAYnRmQG5rZjoBQ%26scisig%3DAAGBfm2D1tnXnxPIQhLCQ1lZ67xJ3atmlw%26oi%3Dscholarr&usg=AOvVaw2Un3fIr2ZUJbkX0xfO4-kr).

## Rimozione feature a contrasto basso o lungo bordi
Con la procedura precedente otteniamo troppi feature points: dobbiamo eliminare le feature spurie date da punti a basso contrasto o bordi che non sono dei veri estremi locali.
Prima di tutto si rimuovono i punti in aree a basso contrasto: si computa la differenza tra il pixel del keypoint e quelli adiacenti se questa è sotto un certo threshold il keypoint viene scartato.
Rimozione dei keypoint dovuti esclusivamente a bordi: lungo i bordi di un oggetto si avrà che lungo la direzione parallela al bordo i valori dei pixel cambiano di poco mentre nelle altre direzioni cambiano di molto questo genera dei keypoint molto sensibili al rumore (che può trasformare punti di sella in estremi locali) per individuare questi falsi estremi si utilizzano gli autovalori della matrice Hessiana se il loro rapporto è maggiore di una certa soglia i punti vengono scartati (il rapporto degli autovalori è proporzionale alla differenza tra la curvatura lungo x e quella lungo y).
| ![burano bordo su un muro](immaginiREADME/burano.jpeg) |
| :--: |
|Bordo che può causare falsi estremi locali|

| ![punto di sella con rumore](immaginiREADME/sella.png) |
| :--: |
|Punto di sella trasformato in estremo locale da rumore|

_Per l'estrazione delle descrizioni delle feature e il matching si guardi la prossima sezione SIFT in Matlab_
## SIFT in Matlab
ATTENZIONE: Eseguire il file `mainSIFT.m` per vedere il codice collegato a questa spiegazione.
### Estrazione keyPoints
In MATLAB per ottenere l'insieme dei punti rappresentativi si usa la funzione `detectSIFTFeatures(Immagine)` che trova gli estremi locali e rimuove gli estremi spuri (punti di sella e punti a basso contrasto). figure 1 e 2 di `mainSIFT.m` mostrano i punti estratti dal logo e dalla foto.
### Estrazione feature 
Dai punti ottenuti nel passaggio precedente `extractFeatures(Immagine,Punti)` estrae le feature in tre passaggi
1. Stima l'orientazione dei keyPoint per avere invarianza alle rotazioni: per ogni keyPoint calcola modulo e orientazione del gradiente in una regione attorno al keyPoint, poi crea un istogramma con asse orrizontale che va da 0 a 360 con n bin e per ogni gradiente calcolato aggiunge il modulo del gradiente al bin corrispondente alla orientazione, il bin con modulo massimo verrà considerato l'orientazione del keyPoint nel punto 2.
2. Si consideri una regione quadrata (di solito 16x16) attorno al keyPoint si divide in m per m quadrati (di solito 4x4) per ogni quadrato si ripete il calcolo del gradiente tramite il metodo dell'istogramma del punto 1 (con 8 bin di solito) l'insieme delle direzioni dei gradienti in questi quadrati verrà preso come vettore di feature del keyPoint.
3. Per poter avere invarianza alle rotazioni dell'immagine agli elementi del vettore di feature del punto 2 si sottrae l'orientazione del keyPoint trovata nel punto 1

_(se si usano i valori soliti per i parametri ogni vettore di feature ha 128 elementi  in MATLAB ci troviamo in questo caso)_
### Matching delle feature
Dopo aver estratto le feature sia dal logo che dalla foto dobbiamo collegare i potenziali keyPoint corrispondenti.

Le feature per ogni keyPoint sono dei vettori in R<sup>128</sup> quindi è possibile utilizzare la distanza euclidea per determinare per ogni keyPoint della foto a quale keyPoint del logo è più vicino in termini di feature, la funzione in Matlab è `matchFeatures(featureLogo,featureFoto)`.

Un parametro importantissimo in questa funzione è `MatchThreshold`, se la distanza tra le feature è > di `MatchThreshold`il match viene scartato ciò permette di gestire la quantità di falsi positivi/falsi negativi, sperimentalmente ho trovato che il migliore valore di questo parametro è 10 o 11 per ottenere il minor numero di falsi negativi. Questo matching si vede nella figure 3 di `mainSIFT.m`.

Infine si rimuovono i match outlier: si stima il tipo di trasformazione avvenuto al logo si può scegliere tra lineare, affine o omografia tramite `estgeotform2d(matchLogo,matchFoto,tipoTrasformazione)` i match che non rispettano la trasformazione determinata vengono scartati e rimangono così solo i match considerati inlier figure 4 su Matlab.

### ROI e censura del logo
Per poter cancellare il logo determiniamo una zona della foto che verrà censurata, nel punto precedente abbiamo determinato la trasformazione che porta dal logo alla foto quindi prendiamo come controimmagini i 4 vertici del logo e applicando la trasformazione a questi 4 punti otterremo i vertici di un poligono nella foto (l'immagine attraverso la trasformazione dei 4 punti nel dominio).
Questo si può fare su Matlab con `transformPointsForward(trasformazione,poligonoLogo)`,dal poligono così ricavato possiamo ricavare una region of interest sulla figura con `drawpolygon` e trasformarla in una maschera con `createMask(roi)` poi applicheremo un filtro interpolatore sulla foto con questa maschera con `regionfill(immagine,mask)` che andrà a censurare il logo nella foto. Il filtro interpolatore tende a funzionare meglio in zone di colore uniforme e senza riflessi (esempio logo hollister) ma in ogni caso riesce a nascondere il logo.
| ![logo in zona con riflessi](immaginiREADME/hollister.jpg) |
| :--: |
|Il logo viene eliminato senza lasciare segni sulla maglia|


| ![logo in zona con riflessi](immaginiREADME/s3Removal.jpg) |
| :--: |
|Il logo viene eliminato ma si nota la censura a causa dei riflessi della scatola|

