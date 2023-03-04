FROM maven:3.9.0-amazoncorretto-8 as builder

ADD . /module
WORKDIR /module

# TODO: cache dependencies in intermediate layer
RUN mvn dependency:resolve
RUN mvn package

FROM amazoncorretto:8

COPY --from=builder /module/target/app-1.0-SNAPSHOT.jar /app.jar

ENV JAVA_OPTS="-Xms128m -Xmx128m -server"
CMD [ "sh", "-c", "java $JAVA_OPTS -jar /app.jar" ]