class Pendulum {
  PVector pivot;           // Posición del eje de giro
  PVector normal;          // Vector normal al plano de oscilación
  float length;            // Longitud del péndulo
  float mass;              // Masa
  float angle;             // Ángulo actual
  float velocity;          // Velocidad angular
  float prev_velocity;     // Velocidad previa, para cálcular cambio dirección
  float acceleration;      // Aceleración angular
  float gravity;           // Gravedad
  float drag;              // Coeficiente de amortiguamiento
  float sphereSize;        // Tamaño de la esfera
  color currentColor;      // Color actual de la esfera 
  color sphereNormalColor; // Color de la esfera en estado normal
  color sphereEventColor;  // Color de la esfera cuando hay un evento
  float barThickness;      // Grosor de la barra
  color barColor;          // Color de la barra
  float minSoundAngle;     // Ángulo por debajo del cual no suena
  float volume;            // volumen local de la muestra
  
  PVector spherePos;       // Posición actual de la esfera
  boolean isMouseOver;     // Si el ratón está sobre la esfera
  boolean isChangingDir;   // Si el la esfera está en un extremo
  boolean bDrawAccel;      // Dibuja aceleraciones
  boolean bGenerateSound;  // Dibuja aceleraciones
  int     colorTimer;      // Temporizador para cambios de color

  int id;
  
  Pendulum(int _id, PVector pivot, PVector normal, float length) {
    this.pivot = pivot.copy();
    this.normal = normal.copy().normalize();
    this.length = length;
    
    // Valores por defecto
    mass = 1.0;
    angle = 0;
    velocity = 0;
    acceleration = 0;
    gravity = 9.81;
    drag = 0.005;
    sphereSize = 20;
    sphereNormalColor = color(0, 70, 40);
    sphereEventColor = color(0, 70, 100);
    setSphereColor(sphereNormalColor);
    barThickness = 3;
    barColor = color(0, 0, 100);
    volume = 0.9;
    id = _id;
    
    updateSpherePosition();
    isMouseOver = false;
  }
  
  void setLength(float newLength) {
    length = newLength;
    updateSpherePosition();
  }
  
  void setMass(float newMass) {
    mass = newMass;
  }
  
  void setSphereSize(float newSize) {
    sphereSize = newSize;
  }
  
  void setSphereColor(color newColor) {
    currentColor = newColor;
  }
  
  void setBarThickness(float newThickness) {
    barThickness = newThickness;
  }
  
  void setBarColor(color newColor) {
    barColor = newColor;
  }
  
  void setDrag(float newDrag) {
    drag = newDrag;
  }

  void playSound() {
    float dB = to_dB(abs(acceleration * volume)*10.0);
    if (soundGlb) playSoundFile(id, dB);
  }
  
  void update() {
    // Calcular aceleración (fórmula del péndulo simple)
    acceleration = -(gravity / length) * sin(angle);
    
    // Actualizar velocidad y ángulo
    velocity += acceleration * dtGlb;
    velocity *= (1 - drag); // Aplicar amortiguamiento
    angle += velocity * dtGlb;

    if (abs(angle) > minAngleGlb) {
      if ( prev_velocity/velocity < 0 ) { // Hay cambio de dirección
        setSphereColor(sphereEventColor); // Más brillante
        playSound();
        colorTimer = 5;
      }  
    }

    // Recupera el color normal si estaba en brillo por evento
    if (colorTimer > 0) {
      colorTimer--;
      if (colorTimer == 0) {
        setSphereColor(sphereNormalColor); 
      }
    }

    prev_velocity = velocity;
    
    updateSpherePosition();
  }
  
  void updateSpherePosition() {
    // Crear dos vectores ortogonales al normal para formar el plano
    PVector u, v;
    if (abs(normal.x) < 0.9) {
      u = new PVector(0, 1, 0).cross(normal).normalize();
    } else {
      u = new PVector(0, 0, 1).cross(normal).normalize();
    }
    v = normal.cross(u).normalize();
    
    // Calcular posición de la esfera en el plano
    PVector offset = u.copy().mult(cos(angle) * length).add(v.copy().mult(sin(angle) * length));
    spherePos = PVector.add(pivot, offset);
  }
  
  boolean isMouseOverSphere() {
    // Proyección correcta 3D → 2D usando matrices de OpenGL
    PVector screenPos = worldToScreen(spherePos);
    float scale = abs(2 * getCameraToScreenDistance() / screenPos.z);
    float circleSize = scale * sphereSize; 

    // Calcular distancia en pantalla
    float screenDistance = dist(mouseX, mouseY, screenPos.x, screenPos.y);
    
    return screenDistance < circleSize/2;
  }

  void keyPressed() {
    if (key == 's' || key == 'S') bGenerateSound = !bGenerateSound;
    if (key == 'd' || key == 'D') bDrawAccel     = !bDrawAccel;
  }
    
  void mouseMoved() {
    // Verificar si el ratón está sobre la esfera
    isMouseOver = isMouseOverSphere();
    
    // Cambiar color si el ratón está sobre la esfera
    if (isMouseOver) {
      setSphereColor(sphereEventColor); // Más brillante
    } else {
      setSphereColor(sphereNormalColor); // Color normal
    }
  }
  
  void mousePressed() {
    if (isMouseOverSphere()) {
      // Acción cuando se hace clic en la esfera
      // Por ejemplo: cambiar el ángulo inicial o dar un impulso
      velocity += mouseToCenterNormalizedDistance() * hitForfeGlb;
    }
  }

  float mouseToCenterNormalizedDistance() {
    PVector screenPos = worldToScreen(spherePos);
    float scale = abs(2 * getCameraToScreenDistance() / screenPos.z);
    float radius = scale * sphereSize / 2.0; 
    return dist(screenPos.x, screenPos.y, mouseX, mouseY) / radius;
  }
  
  void draw() {
    // Dibujar barra
    stroke(barColor);
    strokeWeight(barThickness);
    line(pivot.x, pivot.y, pivot.z, spherePos.x, spherePos.y, spherePos.z);
    
    // Dibujar esfera
    pushMatrix();
    translate(spherePos.x, spherePos.y, spherePos.z);
    fill(currentColor);
    noStroke();
    sphere(sphereSize);
    popMatrix();
    

    if (drawAccelGlb) {
      // Debug: mostrar proyección en pantalla
      PVector screenPos = worldToScreen(spherePos);
      
      // Dibujar punto de proyección en pantalla (modo 2D)
      pushMatrix();

      float scale = abs(2 * getCameraToScreenDistance() / screenPos.z);
      float circleSize = scale * sphereSize; 

      camera(); // Resetear cámara para modo 2D
      hint(DISABLE_DEPTH_TEST);
      stroke(60, 100, 100);
      noFill();
      ellipse(screenPos.x, screenPos.y, circleSize, circleSize);
      stroke(60, 100, 100);
      line(screenPos.x, screenPos.y, screenPos.x - acceleration * 1000, screenPos.y);
      
      // Mostrar información de debug
      // fill(255);
      // textAlign(LEFT);
      // textSize(12);
      // int posY = 1;
      // text("Screen: " + int(screenPos.x) + ", " + int(screenPos.y), 10, 20*posY++);
      // text("Mouse: " + mouseX + ", " + mouseY, 10, 20*posY++);
      // text("Distance: " + dist(mouseX, mouseY, screenPos.x, screenPos.y), 10, 20*posY++);
      
      hint(ENABLE_DEPTH_TEST);
      popMatrix();
    }
  }
}
