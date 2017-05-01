FROM openjdk:8

ADD target/app-1.0-SNAPSHOT.jar /app.jar

ENV JAVA_OPTS="-Xms256m -Xmx256m -server"
ENTRYPOINT [ "sh", "-c", "java $JAVA_OPTS -jar /app.jar" ]