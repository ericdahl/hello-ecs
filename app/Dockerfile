FROM maven:3.9.11-amazoncorretto-25 as builder

WORKDIR /module

# resolve dependencies in their own layer so source-only changes reuse the cache
COPY pom.xml .
RUN mvn -B dependency:go-offline

COPY src ./src
RUN mvn -B clean package

FROM amazoncorretto:25

COPY --from=builder /module/target/app-1.0-SNAPSHOT.jar /app.jar

ENV JAVA_OPTS="-Xms128m -Xmx128m -server"
CMD [ "sh", "-c", "java $JAVA_OPTS -jar /app.jar" ]