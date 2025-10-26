import ddf.minim.*;

Minim minim;
AudioSample[] samples;

String piano_folder = "piano/";
String[] piano_files = { 
  "do3", "do3", "re3", "re3", "mi3", "fa3", 
  "fa3", "sol3", "sol3", "la3", "la3", "si3" 
};

String audio_folder  = piano_folder;
String audio_files[] = piano_files;

void setupSounds(String folder, String[] files) {
    minim   = new Minim(this);
    samples = new AudioSample[files.length];
    for (int i = 0; i < files.length; i++) {
      samples[i] = minim.loadSample(folder + files[i] + ".wav", 512);
    }    
}

void playSoundFile(int index, float volumen) {
  samples[index].setGain(volumen);
  samples[index].trigger();
}
