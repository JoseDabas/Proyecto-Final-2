FROM gradle:8.4-jdk17 as builder

WORKDIR /app

COPY . .

WORKDIR /app/app

RUN chmod +x ./gradlew
RUN ./gradlew clean shadowJar --no-daemon

FROM eclipse-temurin:17-jre

WORKDIR /app

COPY --from=builder /app/app/build/libs/app.jar .

ENV PORT=8080
EXPOSE ${PORT}

CMD ["java", "-jar", "app.jar"]
