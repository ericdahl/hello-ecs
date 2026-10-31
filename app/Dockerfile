FROM maven:3.9.11-amazoncorretto-25 AS builder

WORKDIR /module

COPY . .
RUN mvn clean package

FROM amazoncorretto:25

COPY --from=builder /module/target/app-1.0-SNAPSHOT.jar /app.jar

ENV JAVA_OPTS="-Xms128m -Xmx128m -server"
CMD [ "sh", "-c", "java $JAVA_OPTS -jar /app.jar" ]