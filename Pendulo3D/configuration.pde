import controlP5.*;

ControlP5 cp5;

Group configTab;

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


String configFile = "data/config.json";

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

  // Crear un group que funcionará como “tab”/overlay
  configTab = cp5.addGroup("Configuración")
                 .setPosition(20, 20)
                 .setWidth(350)
                 .setBackgroundColor(color(100, 150))
                 .setLabel("Config Tab")
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
     .setPosition(150, step + (2 * step)*yPos++)
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
     .setPosition(150, step + (2 * step)*yPos)
     .setSize(step, step)
     .setLabel("Draw Axes On/Off")
     .moveTo(configTab);     

  cp5.addToggle("doSave")
     .setPosition(280, step + (2 * step)*yPos++)
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

}

void toggleConfigTab() {
    configVisible = !configVisible;
    if (configVisible) {
      configTab.show();
    } else {
      configTab.hide();
    }  
}
