# Etapa de construcción
FROM gradle:8.4-jdk17 AS builder

WORKDIR /app

# Copiar todo el proyecto
COPY . .

# Dar permisos de ejecución al wrapper de Gradle
RUN chmod +x ./gradlew

# Limpiar caché corrupta y compilar el JAR con shadowJar (sin modo aislado)
RUN ./gradlew clean :app:shadowJar --no-daemon

# Etapa final (imagen más ligera)
FROM eclipse-temurin:17-jre

WORKDIR /app

# Copiar el JAR generado desde el builder
COPY --from=builder /app/app/build/libs/*.jar ./app.jar

# Comando para ejecutar el JAR
ENTRYPOINT ["java", "-jar", "app.jar"]
