# Etapa de build
FROM gradle:8.4-jdk17 AS builder
WORKDIR /app

# Copiar archivos raíz necesarios para el build
COPY gradlew gradlew.bat settings.gradle ./

# Copiar configuración del wrapper (solo si existe la carpeta 'gradle')
COPY gradle ./gradle

# Copiar el código fuente del subproyecto
COPY app ./app

# Dar permisos al wrapper
RUN chmod +x ./gradlew

# Generar el JAR con shadowJar
RUN ./gradlew :app:clean :app:shadowJar --no-daemon

# Etapa final
FROM eclipse-temurin:17-jre
WORKDIR /app

# Copiar el jar generado desde la etapa anterior
COPY --from=builder /app/app/build/libs/*.jar ./app.jar

CMD ["java", "-jar", "app.jar"]

