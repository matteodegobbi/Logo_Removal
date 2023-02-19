package com.example.mandastringhe


import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Bundle
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.compose.setContent
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.*
import androidx.compose.material.Button
import androidx.compose.material.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import coil.compose.rememberAsyncImagePainter
import com.example.mandastringhe.ui.theme.MandaStringheTheme
import kotlinx.coroutines.*
import java.io.BufferedReader
import java.io.ByteArrayOutputStream
import java.io.InputStreamReader
import java.net.ConnectException
import java.net.Socket

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MandaStringheTheme {
                MandaStringheApp(modifier = Modifier)//Composable principale della app
            }
        }
    }
}

@Composable
fun MandaStringheApp(modifier: Modifier) {
    val coroutineScope = rememberCoroutineScope()
    val contesto=LocalContext.current
    var foto by remember { mutableStateOf(BitmapFactory.decodeResource(contesto.resources,R.drawable.kot)) }
    val galleryLauncher =
        rememberLauncherForActivityResult(ActivityResultContracts.GetContent()) { uri ->
            //lambda function che legge il file dal URI e ottiene una Bitmap, non è necessario avere la path completa
            if (uri!=null){//evita il crash se si esce dal filepicker senza scegliere
                foto= BitmapFactory.decodeStream(contesto.contentResolver.openInputStream(uri))
            }

        }

    Column(modifier = Modifier.fillMaxSize()) {
        Spacer(modifier = Modifier.height(35.dp))//margine
        Box(modifier = Modifier
            .weight(1f)
            .align(Alignment.CenterHorizontally)
            .padding(
                horizontal = 35.dp
            )){
            Image(contentDescription ="foto scelta ", painter = rememberAsyncImagePainter(foto) )//disegnatore dell'Immagine asincrono
        }

        Row(modifier = Modifier
            .weight(0.2f)
            .padding(5.dp)) {
            Button(modifier = Modifier
                .fillMaxSize()
                .weight(0.5f)
                .padding(5.dp),onClick = {
                //coRoutine asincrona che gira sui Thread IO per le operazioni sui socket
                coroutineScope.launch {
                    withContext(Dispatchers.IO) {
                        mandaMessaggioTCP(foto)
                    }
                }

            }) {
                Text(text = "Invia messaggio")
            }
            Button(modifier = Modifier
                .fillMaxSize()
                .weight(0.5f)
                .padding(5.dp), onClick = {
                galleryLauncher.launch("image/*")
            }) {
                Text(text = "Fai foto")
            }
        }
        Spacer(modifier = Modifier.height(10.dp))

    }
}



suspend fun mandaMessaggioTCP(foto:Bitmap) {//funzione asincrona che gestisce i socket e invia l'immagine
    coroutineScope {
        try {//try per evitare crash se si continua a premere invia
            val client = Socket("192.168.1.55", 4316)//crea socket

            //val input = BufferedReader(InputStreamReader(client.inputStream))


            val stream = ByteArrayOutputStream()
            foto.compress(Bitmap.CompressFormat.PNG, 100, stream)//comprime in PNG la Bitmap per l'invio
            val biteArrayDaInviare = stream.toByteArray()
            val sequenzaFine: ByteArray = byteArrayOf(
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0
            )//ending sequence 32 byte di NULL

            //invio del byteArray contenente la Bitmap compressa
            client.getOutputStream().write(biteArrayDaInviare)

            //invio del byteArray contenente la ending sequence
            client.getOutputStream().write(sequenzaFine)
            client.getOutputStream().flush()
            println("Client sending image")

            client.close()

        }catch (e: ConnectException){
            Log.println(Log.INFO,"LEGGI","connection error")//Log nel caso di errore di connessione
        }
    }

}