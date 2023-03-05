FROM maven:3.9.0-amazoncorretto-8 as builder

WORKDIR /module

# try to leverage docker cache for faster builds (doesn't work great with maven)
COPY pom.xml .
RUN mvn -B -s /usr/share/maven/ref/settings-docker.xml dependency:resolve-plugins dependency:go-offline
COPY . .
RUN mvn -B -s /usr/share/maven/ref/settings-docker.xml -Dspring-boot.repackage.skip=true clean package

FROM amazoncorretto:8

COPY --from=builder /module/target/app-1.0-SNAPSHOT.jar /app.jar

ENV JAVA_OPTS="-Xms128m -Xmx128m -server"
CMD [ "sh", "-c", "java $JAVA_OPTS -jar /app.jar" ]

HEALTHCHECK --timeout=3s --start-period=120s CMD curl -f http://localhost:8080 || exit 1