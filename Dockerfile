FROM gradle:8.4-jdk17 as builder

WORKDIR /app

COPY . .

RUN chmod +x gradlew
RUN ./gradlew clean shadowJar --no-daemon && ls -lh build/libs

# --- Final image ---
FROM eclipse-temurin:17-jre

WORKDIR /app

COPY --from=builder /app/build/libs/*.jar ./app.jar

# Usa la misma variable que Railway usa por defecto
ENV PORT=8080

EXPOSE ${PORT}

CMD ["java", "-jar", "app.jar"]
