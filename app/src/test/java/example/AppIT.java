package example;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.testcontainers.containers.GenericContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Boots the full app against a real Redis. Configures Redis the same way the ECS
 * task does (spring.data.redis.host, i.e. SPRING_DATA_REDIS_HOST), so a wrong
 * property name fails here instead of in production.
 */
@Testcontainers
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT, properties = "HOSTNAME=it-host")
class AppIT {

    @Container
    static GenericContainer<?> redis = new GenericContainer<>("redis:7-alpine").withExposedPorts(6379);

    @DynamicPropertySource
    static void redisProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.data.redis.host", redis::getHost);
        registry.add("spring.data.redis.port", () -> redis.getMappedPort(6379));
    }

    @LocalServerPort
    private int port;

    private final HttpClient http = HttpClient.newHttpClient();

    private HttpResponse<String> get(String path) throws Exception {
        return http.send(HttpRequest.newBuilder(URI.create("http://localhost:" + port + path)).build(),
                HttpResponse.BodyHandlers.ofString());
    }

    @Test
    void indexIncrementsCounterInRedis() throws Exception {
        HttpResponse<String> first = get("/");
        HttpResponse<String> second = get("/");

        assertThat(first.statusCode()).isEqualTo(200);
        assertThat(first.body()).isEqualTo("Hello from it-host (count is 1)");
        assertThat(second.body()).isEqualTo("Hello from it-host (count is 2)");
    }

    @Test
    void healthIsUpWhenRedisIsReachable() throws Exception {
        HttpResponse<String> health = get("/actuator/health");

        assertThat(health.statusCode()).isEqualTo(200);
        assertThat(health.body()).contains("\"status\":\"UP\"");
    }
}
