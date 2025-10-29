import peasy.*;

PeasyCam cam;

int N_PENDULUM = 12;

Pendulum pendulum;
ArrayList<Pendulum> pendulum_list;

void setup() {
  size(800, 600, P3D);
  cam = new PeasyCam(this, 400);
  
  colorMode(HSB, 360, 100, 100, 255);

  // Lista de péndulos
  pendulum_list = new ArrayList<Pendulum>();
  // Crear péndulo en el origen con normal hacia arriba
  for(int i = 0; i < N_PENDULUM; i++) {
    PVector pivot  = new PVector(-50 * (N_PENDULUM-1)/2 + 50 * i, 0, 0);
    PVector normal = new PVector(1, 0, 0);
    Pendulum p = new Pendulum(i, pivot, normal, 150 - 10 * i);
    pendulum_list.add(p);
  }

  // Sonidos
  setupSounds(audio_folder, audio_files);
  setupVolumes(audio_volumes);
  // Panel de control
  setupConfigTab();
  // Disable autodraw to allow overlay panel
  cp5.setAutoDraw(false);

}

void draw() {
  background(0);
  
  if (lightsGlb) lights();
  if (axesGlb) drawAxes();
  
  // Actualizar péndulo
  for(Pendulum p : pendulum_list) p.update();
  
  // Dibujar péndulo
  for(Pendulum p : pendulum_list) p.draw();

  // --- Control de PeasyCam según el ratón ---
  cam.setActive(!cp5.isMouseOver()); 

  // --- UI EN 2D (overlay) ---
  pushMatrix();
  pushStyle();
  noLights();
  camera();                  // Resetear cámara para modo 2D  
  hint(DISABLE_DEPTH_TEST);  // evita que la UI se vea detrás de objetos 3D
  cp5.draw();                // dibuja la UI plana sobre la escena
  hint(ENABLE_DEPTH_TEST);
  popStyle();
  popMatrix();
}

void mouseMoved() {
  for(Pendulum p : pendulum_list) p.mouseMoved();
}

void mousePressed() {
  for(Pendulum p : pendulum_list) p.mousePressed();
}

void keyPressed() {
  if (key == 's' || key == 'S') saveConfig(configFile);
}