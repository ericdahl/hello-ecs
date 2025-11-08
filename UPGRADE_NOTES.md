# Dependency Upgrade Notes

## Changes Made

### Java Version
- **Updated from**: Java 23
- **Updated to**: Java 21
- **Reason**: Java 21 is the current LTS (Long Term Support) version with better stability and wider support

### Maven Version
- **Updated from**: Maven 3.9.9
- **Updated to**: Maven 3.9.11
- **Location**: Dockerfile builder stage

## Recommended Spring Boot Upgrade

### Current Version
- **Spring Boot**: 3.3.5 (released November 2024)

### Recommended Target Version
- **Spring Boot 3.4.11** (released October 23, 2025)
  - 55 bug fixes, documentation improvements, and dependency upgrades
  - Stable release in the 3.4.x line
  - Requires Java 17+ (compatible with Java 21)

### Alternative Version
- **Spring Boot 3.5.x** series may be available pending Maven Central publication
- **Spring Boot 4.0.0** is in RC (Release Candidate) stage - not recommended for production

## Upgrade Path

To upgrade to Spring Boot 3.4.11 when network access permits:

1. Update `app/pom.xml`:
```xml
<parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>3.4.11</version>
</parent>
```

2. Verify the application builds:
```bash
cd app
mvn clean package
```

3. Run tests:
```bash
mvn test
```

4. Test the application locally with Redis:
```bash
docker run -d -p 6379:6379 redis:latest
java -jar target/app-1.0-SNAPSHOT.jar
```

5. Verify the endpoint:
```bash
curl http://localhost:8080
```

## Current Dependencies

All managed by Spring Boot parent POM:
- `spring-boot-starter-web` (with Jetty instead of Tomcat)
- `spring-boot-starter-jetty`
- `spring-boot-starter-data-redis`
- `spring-boot-starter-actuator`

## Compatibility Notes

- Java 21 is compatible with all Spring Boot 3.x versions (requires minimum Java 17)
- No breaking changes expected between Spring Boot 3.3.5 → 3.4.11
- Review release notes at: https://github.com/spring-projects/spring-boot/wiki/Spring-Boot-3.4-Release-Notes
