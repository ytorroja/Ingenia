import ddf.minim.*;

Minim minim;
AudioSample[] samples;

String[] soundSets = { "piano/", "campo/" };
String[][] soundFiles = {
  { 
    "do3", "do3", "re3", "re3", "mi3", "fa3", 
    "fa3", "sol3", "sol3", "la3", "la3", "si3" 
  },
  { 
    "do3", "do3", "re3", "re3", "mi3", "fa3", 
    "fa3", "sol3", "sol3", "la3", "la3", "si3" 
  }    
};

float[][] soundVolumes = {
  { 
    0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 
    0.9, 0.9, 0.9, 0.9, 0.9, 0.9
  },
  { 
    0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 
    0.9, 0.9, 0.9, 0.9, 0.9, 0.9
  }
};

int    currentSoundSet = 0;

String audio_folder  = soundSets[currentSoundSet];
String audio_files[] = soundFiles[currentSoundSet];
float  audio_volumes[] = soundVolumes[currentSoundSet];

// Calcula el volumen en dB afectado por el volumen global
float to_dB(float linear) {
  float dB = 20 * log(max(constrain(linear, 0, 1), 0.0001))/log(10);
  return dB;
}

void setupSounds(String folder, String[] files) {
    minim   = new Minim(this);
    samples = new AudioSample[files.length];
    for (int i = 0; i < files.length; i++) {
      samples[i] = minim.loadSample(folder + files[i] + ".wav", 512);
    }    
}

void setupVolumes(float volumes[]) {
  for (int i = 0; i < volumes.length; i++) {
    audio_volumes[i] = volumes[i];
  }    
}

void playSoundFile(int index, float dB) {

  float final_dB = dB + to_dB(audio_volumes[index]) + to_dB(volumeGlb);
  samples[index].setGain(final_dB);
  samples[index].trigger();
}
