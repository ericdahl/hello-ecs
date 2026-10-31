FROM maven:3.9.11-amazoncorretto-25 as builder

WORKDIR /module

COPY . .
RUN mvn clean package

FROM amazoncorretto:25

COPY --from=builder /module/target/app-1.0-SNAPSHOT.jar /app.jar

# run as an unprivileged user (the base image has no useradd; nobody is uid 65534)
USER nobody

ENV JAVA_OPTS="-Xms128m -Xmx128m -server"
CMD [ "sh", "-c", "java $JAVA_OPTS -jar /app.jar" ]