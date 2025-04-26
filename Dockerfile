# --- Etapa de compilación ---
FROM gradle:8.4-jdk17 as builder

WORKDIR /app

# Copiamos todos los archivos necesarios
COPY . .
RUN ls -l && ls -l gradlew

# Aseguramos permisos para gradlew
RUN chmod +x gradlew

# Eliminamos caché corrupta y generamos el JAR con shadow
RUN rm -rf .gradle
RUN ./gradlew clean shadowJar --no-daemon -Dorg.gradle.unsafe.isolated-projects=true

# --- Imagen final ligera ---
FROM eclipse-temurin:17-jre

WORKDIR /app

# Copiamos el jar generado desde el builder
COPY --from=builder /app/build/libs/*.jar ./app.jar

# Railway usa esta variable para el puerto
ENV PORT=8080

EXPOSE ${PORT}

# Ejecutamos el JAR
CMD ["java", "-jar", "app.jar"]
