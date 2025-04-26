# Fase de construcción
FROM gradle:8.4-jdk17 AS builder

# Establecer el directorio de trabajo en el contenedor
WORKDIR /app

# Copiar los archivos necesarios para el build (gradle, settings.gradle, gradlew)
COPY gradlew gradlew.bat settings.gradle ./
COPY gradle ./gradle
COPY app ./app

# Dar permisos de ejecución a gradlew
RUN chmod +x ./gradlew

# Limpiar el directorio de Gradle y generar el jar con shadowJar
RUN ./gradlew :app:clean :app:shadowJar --no-daemon

# Fase final: imagen ligera para ejecutar el JAR
FROM eclipse-temurin:17-jre

# Establecer el directorio de trabajo en la imagen final
WORKDIR /app

# Copiar el archivo .env al contenedor
COPY .env .env

# Copiar el JAR generado desde la fase de construcción
COPY --from=builder /app/app/build/libs/*.jar ./app.jar

# Exponer el puerto (ajústalo según sea necesario)
EXPOSE 8080

# Comando para ejecutar el JAR
CMD ["java", "-jar", "app.jar"]


