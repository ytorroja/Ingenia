import controlP5.*;
import java.util.*;

ControlP5 cp5;

Group configTab;
Group soundTab;

boolean configVisible = false; // overlay oculto por defecto

// Parámetros que queremos controlar
float   dtGlb        = 0.3;
float   drag         = 0.05;
float   volumeGlb    = 0.9;
float   minAngleGlb  = 0.05;
float   hitForfeGlb  = 0.4;
boolean soundGlb     = true;
boolean drawAccelGlb = false;
boolean axesGlb      = false;
boolean lightsGlb    = true; 
boolean doSave       = false;

String  configFile = "data/config.json";

void setupConfigTab() {
  
  cp5 = new ControlP5(this);

  String filename = "config.json";
  File f = new File(dataPath(filename));
  if (f.exists()) {
    loadConfig(filename);
  } else {
    println("No config file. Using default values.");
  }

  
  int yPos = 0;

  int step = 15;

  int tabWidth = 300;

  int numTab = 0;

  // Crear un group que funcionará como “tab”/overlay
  configTab = cp5.addGroup("Configuración")
                .setPosition(step + (tabWidth + step) * numTab++ , step)
                .setWidth(tabWidth)
                .setBackgroundColor(color(100, 150))
                .setLabel("Config Tab")
                // .activateEvent(true)
                .show(); 

  cp5.addSlider("dtGlb")
    .setLabel("Speed")
    .setRange(0, 1)
    .setValue(dtGlb)
    .setPosition(10, step + (2 * step)*yPos++)
    .setSize(10*step, step)
    .moveTo(configTab);

  cp5.addSlider("hitForfeGlb")
    .setLabel("Hit Max Force")
    .setRange(0, 1.0)
    .setValue(hitForfeGlb)
    .setPosition(10, step + (2 * step)*yPos++)
    .setSize(10*step, step)
    .setDecimalPrecision(2)
    .moveTo(configTab);
     
  cp5.addSlider("minAngleGlb")
    .setLabel("Min sound angle")
    .setRange(0, 0.2)
    .setValue(minAngleGlb)
    .setPosition(10, step + (2 * step)*yPos++)
    .setSize(10*step, step)
    .setDecimalPrecision(2)
    .moveTo(configTab);
 
  cp5.addSlider("drag")
    .setLabel("Drag")
    .setRange(0, 0.1)
    .setValue(drag)
    .setPosition(10, step + (2 * step)*yPos++)
    .setSize(10*step, step)
    .setDecimalPrecision(3)
    .moveTo(configTab)
    .onChange( (event) -> {
      drag = event.getController().getValue();
      for(Pendulum p : pendulum_list) p.setDrag(drag);
    });   

  cp5.addSlider("volumeGlb")
    .setLabel("Volumen")
    .setRange(0, 1)
    .setValue(volumeGlb)
    .setPosition(10, step + (2 * step)*yPos++)
    .setSize(10*step, step)
    .moveTo(configTab);

  cp5.addToggle("soundGlb")
    .setValue(soundGlb)
    .setPosition(10, step + (2 * step)*yPos)
    .setSize(step, step)
    .setLabel("Generate Sound On/Off")
    .moveTo(configTab);


  cp5.addToggle("lightsGlb")
    .setValue(lightsGlb)
    .setPosition(tabWidth/2, step + (2 * step)*yPos++)
    .setSize(step, step)
    .setLabel("Render lights On/Off")
    .moveTo(configTab);     


  cp5.addToggle("drawAccelGlb")
    .setValue(drawAccelGlb)
    .setPosition(10, step + (2 * step)*yPos)
    .setSize(step, step)
    .setLabel("Draw Accel On/Off")
    .moveTo(configTab);

  cp5.addToggle("axesGlb")
    .setValue(axesGlb)
    .setPosition(tabWidth/2, step + (2 * step)*yPos)
    .setSize(step, step)
    .setLabel("Draw Axes On/Off")
    .moveTo(configTab);     

  cp5.addToggle("doSave")
    .setPosition(tabWidth - step, step + (2 * step)*yPos++)
    .setSize(step, step)
    .setLabel("Save")
    .setColorActive(color(0, 70, 100))
    .moveTo(configTab)
    .onRelease( (event) -> {
      doSave = ((Toggle)event.getController()).getState();
      if (doSave) {
        saveConfig(configFile);
        ((Toggle)event.getController()).toggle(); // vuelve el toggle a su estado de reposo
      }
    });

  soundTab = cp5.addGroup("Sonidos")
                .setPosition(step + (tabWidth + step) * numTab++ , step)
                .setWidth(tabWidth)
                .setBackgroundColor(color(100, 150))
                .setLabel("Sounds Tab")
                // .activateEvent(true)
                .close();

  yPos = 0;
  cp5.addScrollableList("setSoundSet")
    .setPosition(10, step + (2 * step)*yPos++)
    .setSize(10* step, 3 * step)
    .setBarHeight(step)
    .setItemHeight(step)
    .addItems(soundSets)
    .setLabel("Sounds Sets")
    .setValue(currentSoundSet)
    .moveTo(soundTab)
    .close()
    .addListener( event -> {
      int n = int(((ScrollableList)event.getController()).getValue());
      setupSounds(soundSets[n], soundFiles[n]);
      setupVolumes(soundVolumes[n]);
    });
  
  yPos++;
  for(int i = 0; i < audio_volumes.length; i++) {
    cp5.addSlider("vol_" + i)
      .setRange(0, 1)
      .setValue(audio_volumes[i])
      .setPosition(10 + 2 * step * i, step + (2 * step)*yPos)
      .setSize(step, step * 9)
      // .setSliderMode(Slider.FLEXIBLE)
      .setLabel("V" + (i + 1))
      .moveTo(soundTab)
      .addListener( event -> {
        int idx = int(event.getController().getName().substring(4));
        audio_volumes[idx] = event.getController().getValue();
      });             
   }

   yPos++;
}

void controlEvent(ControlEvent event) {
  // Verifica si el evento viene de un tab
  if (event.isGroup()) {
    Group tab = (Group)event.getGroup();
    if (tab == soundTab) configTab.close();
    if (tab == configTab) soundTab.close();
  }
}
