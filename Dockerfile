# Fase de construcción
FROM gradle:8.4-jdk17 AS builder

WORKDIR /app

# Copiar archivos necesarios para el build
COPY gradlew gradlew.bat settings.gradle ./
COPY gradle ./gradle
COPY app ./app

# Asegurar certificados actualizados en la etapa de build (no es estrictamente necesario, pero bien)
RUN apt-get update && apt-get install -y ca-certificates

RUN chmod +x ./gradlew

# Compilar y generar el JAR con shadowJar
RUN ./gradlew :app:clean :app:shadowJar --no-daemon

# Fase final: imagen liviana para correr el JAR
FROM eclipse-temurin:17-jre

WORKDIR /app

# Asegurar certificados SSL actualizados en la imagen final
RUN apt-get update && apt-get install -y ca-certificates && update-ca-certificates

# Configurar JAVA_TOOL_OPTIONS para confiar en los certificados del sistema y forzar TLSv1.2
ENV JAVA_TOOL_OPTIONS="-Djavax.net.ssl.trustStore=/etc/ssl/certs/java/cacerts -Djavax.net.ssl.trustStorePassword=changeit -Djdk.tls.client.protocols=TLSv1.2"

# Copiar el JAR generado desde el builder
COPY --from=builder /app/app/build/libs/*.jar ./app.jar

EXPOSE 8080

# Ejecutar el JAR
CMD ["java", "-jar", "app.jar"]
