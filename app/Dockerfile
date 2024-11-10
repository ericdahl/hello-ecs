FROM maven:3.9.9-amazoncorretto-23 as builder

WORKDIR /module

COPY . .
RUN mvn clean package

FROM amazoncorretto:23

COPY --from=builder /module/target/app-1.0-SNAPSHOT.jar /app.jar

ENV JAVA_OPTS="-Xms128m -Xmx128m -server"
CMD [ "sh", "-c", "java $JAVA_OPTS -jar /app.jar" ]