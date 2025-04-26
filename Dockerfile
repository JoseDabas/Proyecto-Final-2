# Etapa de construcción
FROM gradle:8.4-jdk17 AS builder

# Crear y moverse al directorio de trabajo
WORKDIR /app

# Copiar archivos raíz necesarios para el build
COPY gradlew gradlew.bat settings.gradle ./
COPY gradle ./gradle  # si tienes carpeta gradle (configuración del wrapper)

# Copiar el código fuente del proyecto
COPY app ./app

# Dar permisos al wrapper
RUN chmod +x ./gradlew

# Ejecutar shadowJar en el subproyecto app
RUN ./gradlew :app:clean :app:shadowJar --no-daemon

# Etapa final: imagen liviana
FROM eclipse-temurin:17-jre

WORKDIR /app

# Copiar el JAR generado
COPY --from=builder /app/build/libs/*.jar ./app.jar

# Ejecutar la aplicación
ENTRYPOINT ["java", "-jar", "app.jar"]
