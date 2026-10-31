FROM maven:3.9.11-amazoncorretto-25 as builder

WORKDIR /module

COPY . .
RUN mvn clean package

FROM amazoncorretto:25

COPY --from=builder /module/target/app-1.0-SNAPSHOT.jar /app.jar

# size the heap from the container memory limit instead of a fixed value; leave the
# rest for metaspace, thread stacks, code cache and direct buffers (~125 MiB measured)
ENV JAVA_OPTS="-XX:MaxRAMPercentage=65 -server"
CMD [ "sh", "-c", "java $JAVA_OPTS -jar /app.jar" ]