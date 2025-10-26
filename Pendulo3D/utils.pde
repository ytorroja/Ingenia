void backupFile(String filename) {
  String src = filename;
  String dest = filename + ".bck";
  File f = new File(dataPath(src));
  if (f.exists()) {
    byte[] data = loadBytes(src);
    saveBytes(dest, data);
  }
}

// Guardar configuración
void saveConfig(String filename) {
  JSONObject config = new JSONObject();
  config.setFloat("dtGlb", dtGlb);
  config.setFloat("drag", drag);
  config.setFloat("volumeGlb", volumeGlb);
  config.setFloat("hitForfeGlb", hitForfeGlb);
  config.setFloat("minAngleGlb", minAngleGlb);
  config.setString("audio_folder", audio_folder);

  JSONArray filesList = new JSONArray();
  for (String f : audio_files) filesList.append(f);
  config.setJSONArray("audio_files", filesList);   

  backupFile(filename);
  saveJSONObject(config, filename);

  println("Config. saved to " + filename);

}

// Cargar configuración
void loadConfig(String filename) {
  JSONObject config = loadJSONObject(filename);
  dtGlb        = config.getFloat("dtGlb");
  drag         = config.getFloat("drag");
  volumeGlb    = config.getFloat("volumeGlb");
  hitForfeGlb  = config.getFloat("hitForfeGlb");
  minAngleGlb  = config.getFloat("minAngleGlb");
  audio_folder = config.getString("audio_folder");

  JSONArray filesList = config.getJSONArray("audio_files");
  audio_files = new String[filesList.size()];
  for (int i = 0; i < filesList.size(); i++) {
    audio_files[i] = filesList.getString(i);
  }

  println("Config. loaded from " + filename);

}

// Calcula el volumen en dB afectado por el volumen global
float volume_dB(float linear) {
  float dB = 20 * log(max(constrain(linear * volumeGlb, 0, 1), 0.0001))/log(10);
  return dB;
}

void drawAxes() {
  pushStyle();
  colorMode(RGB);
  strokeWeight(3);
  
  // Eje X (rojo)
  stroke(255, 0, 0);
  line(0, 0, 0, 200, 0, 0);
  
  // Eje Y (verde)
  stroke(0, 255, 0);
  line(0, 0, 0, 0, 200, 0);
  
  // Eje Z (azul)
  stroke(0, 0, 255);
  line(0, 0, 0, 0, 0, 200);
  
  noStroke();
  popStyle();
}

// Función global para que la clase Pendulum pueda acceder a la cámara
PeasyCam getCamera() {
  return cam;
}

float getFOVFromProjection() {
  PGraphics pg = g;
  PMatrix3D proj = ((PGraphics3D) pg).projection;

  // En una matriz de proyección de perspectiva estándar:
  // proj.m11 = 1 / tan(fov/2)
  float m11 = proj.m11;

  // Evitar división por cero
  if (m11 == 0) return 0;

  // fov = 2 * atan(1 / m11)
  float fov = 2 * atan(1.0 / m11);

  return fov;
}

float getCameraToScreenDistance() {
  PGraphics pg = g;
  PMatrix3D proj = ((PGraphics3D) pg).projection;
  float m11 = proj.m11;
  return (height / 2.0) * m11;  // distancia focal en píxeles
}

float cameraSpaceDepth(PVector worldPt) {
  PGraphics pg = g;
  PMatrix3D mv = ((PGraphics3D) pg).modelview;
  
  // Transformar el punto con la matriz modelview
  float x = worldPt.x;
  float y = worldPt.y;
  float z = worldPt.z;
  float w = 1.0;
  
  float mvx = mv.m00*x + mv.m01*y + mv.m02*z + mv.m03*w;
  float mvy = mv.m10*x + mv.m11*y + mv.m12*z + mv.m13*w;
  float mvz = mv.m20*x + mv.m21*y + mv.m22*z + mv.m23*w;
  float mvw = mv.m30*x + mv.m31*y + mv.m32*z + mv.m33*w;

  if (mvw == 0) return Float.POSITIVE_INFINITY;

  // Coordenada Z en espacio de cámara (positivo delante de la cámara)
  float zCam = - (mvz / mvw);
  return zCam;
}


PVector worldToScreen(PVector worldPt) {
  PGraphics pg = g;
  PMatrix3D modelView = ((PGraphics3D)pg).modelview;
  PMatrix3D projection = ((PGraphics3D)pg).projection;
  int[] viewport = {0, 0, pg.width, pg.height};

  float[] in = {worldPt.x, worldPt.y, worldPt.z, 1.0};
  float[] mvOut = new float[4];
  float[] projOut = new float[4];

  // ModelView transform
  mvOut[0] = modelView.m00*in[0] + modelView.m01*in[1] + modelView.m02*in[2] + modelView.m03*in[3];
  mvOut[1] = modelView.m10*in[0] + modelView.m11*in[1] + modelView.m12*in[2] + modelView.m13*in[3];
  mvOut[2] = modelView.m20*in[0] + modelView.m21*in[1] + modelView.m22*in[2] + modelView.m23*in[3];
  mvOut[3] = modelView.m30*in[0] + modelView.m31*in[1] + modelView.m32*in[2] + modelView.m33*in[3];

  // Projection transform
  projOut[0] = projection.m00*mvOut[0] + projection.m01*mvOut[1] + projection.m02*mvOut[2] + projection.m03*mvOut[3];
  projOut[1] = projection.m10*mvOut[0] + projection.m11*mvOut[1] + projection.m12*mvOut[2] + projection.m13*mvOut[3];
  projOut[2] = projection.m20*mvOut[0] + projection.m21*mvOut[1] + projection.m22*mvOut[2] + projection.m23*mvOut[3];
  projOut[3] = projection.m30*mvOut[0] + projection.m31*mvOut[1] + projection.m32*mvOut[2] + projection.m33*mvOut[3];

  if (projOut[3] == 0.0) return null; // evita división por cero

  float winX = viewport[0] + (1 + projOut[0]/projOut[3]) * viewport[2] / 2.0;
  float winY = viewport[1] + (1 - projOut[1]/projOut[3]) * viewport[3] / 2.0;
  float winZ = (1 + projOut[2]/projOut[3]) / 2.0;

  // Distancia focal en pixel de la cámara
  float fpx = getCameraToScreenDistance(); // cameraPos.dist(worldPt);

  // FOV actual de la cámara
  // float fov = getFOVFromProjection();

  float z = cameraSpaceDepth(worldPt);
  
  return new PVector(winX, winY, z);
}
