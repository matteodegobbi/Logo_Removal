# Logo Removal
## Cos'è SIFT? (Scale Invariant Feature Trasnform)
SIFT è un algoritmo di estrazione di feature da un'immagine che prende in input un'immagine e restituisce un sottoinsieme di punti rappresentativi dell'immagine (keyPoints) con delle corrispondenti descrizioni dei punti che possono essere utilizzate per trovare corrispodenze tra immagini diverse, SIFT è invariante a cambiamenti di scala e in gran parte anche a rotazioni.

## Scale Space (invarianza spaziale e eliminazione rumore)
SIFT prima di tutto costruisce lo scale space: crea N versioni scalate dell'immagine originale (in modo da ottenere scale-invariance SI) da ognuna di queste N versioni crea altre M immagini con livelli diversi di gaussian-blur. Alla fine della procedura avremo NxM immagini. Ogni livello di scalatura viene chiamato ottava e contiene M versioni con blur diversi

## Difference of Gaussian (DOG)
Poi SIFT ottiene un nuovo set di immagini per ogni ottava sottranedo dalle immagini con poco blur (varianza della gaussiana bassa) quelle con molto blur mantenedo quindi le componenti ad alta frequenza e attenuando quelle a bassa frequenza.

Su questo set chiamato DOG difference of gaussians per ogni immagine si trovano gli estremi locali. Per farlo si compara ogni pixel con gli 8 che lo circondano nella immagine e con i 9 corrispondenti nell'ottava precedente e i 9 corrispondenti nell'ottava successiva se il pixel è > di questi altri 26 (o < di tutti) allora viene preso come feature.

### approx del Laplace 
la DOG approssima l'operatore laplaciano con la differenza che non deve essere normalizzato per la scala (Laplaciano è scale variant perché le immagini a risoluzione più alta hanno pendenze più basse ovvero valori delle derivate più bassi)
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
