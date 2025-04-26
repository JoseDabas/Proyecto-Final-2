# Etapa de build
FROM gradle:8.4-jdk17 AS builder
WORKDIR /app

# Copiar archivos necesarios para construir
COPY gradlew gradlew.bat settings.gradle ./
COPY gradle ./gradle           # Solo si tienes esta carpeta
COPY app ./app                 # Copia la carpeta del subproyecto

# Dar permisos al wrapper
RUN chmod +x ./gradlew

# Limpiar cache previa (opcional) y generar el JAR sombreado del subproyecto
RUN ./gradlew :app:clean :app:shadowJar --no-daemon

# Etapa final de ejecución
FROM eclipse-temurin:17-jre
WORKDIR /app

# Copiar solo el JAR generado desde el builder
COPY --from=builder /app/app/build/libs/*.jar ./app.jar

# Ejecutar
CMD ["java", "-jar", "app.jar"]

