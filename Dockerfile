# --------- Fase 1: Construcción del JAR ---------
FROM gradle:8.4-jdk17 AS builder

# Establecer directorio de trabajo
WORKDIR /app

# Copiar archivos de configuración y proyecto
COPY gradlew gradlew.bat settings.gradle ./ 
COPY gradle ./gradle
COPY app ./app

# Dar permisos a gradlew
RUN chmod +x ./gradlew

# Construir el proyecto (shadowJar genera un JAR ejecutable)
RUN ./gradlew :app:clean :app:shadowJar --no-daemon

# --------- Fase 2: Imagen final optimizada ---------
FROM eclipse-temurin:17-jre

# Establecer directorio de trabajo
WORKDIR /app

# Instalar certificados raíz y actualizar truststore de Java
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl \
    && update-ca-certificates \
    && keytool -importkeystore \
         -srckeystore /etc/ssl/certs/java/cacerts \
         -destkeystore /etc/ssl/certs/java/cacerts \
         -srcstorepass changeit \
         -deststorepass changeit \
         -noprompt || true \
    && rm -rf /var/lib/apt/lists/*

# Forzar opciones de SSL/TLS en la JVM
ENV JAVA_TOOL_OPTIONS="-Djavax.net.ssl.trustStore=/etc/ssl/certs/java/cacerts -Djavax.net.ssl.trustStorePassword=changeit -Djdk.tls.client.protocols=TLSv1.2"

# Copiar el JAR construido
COPY --from=builder /app/app/build/libs/*.jar ./app.jar

# Exponer el puerto (ajústalo si tu app corre en otro puerto)
EXPOSE 8080

# Comando para ejecutar el JAR
CMD ["java", "-jar", "app.jar"]
