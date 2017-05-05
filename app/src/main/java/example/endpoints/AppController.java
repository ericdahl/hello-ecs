package example.endpoints;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class AppController {

    @Value("${HOSTNAME:unknown}")
    private String hostname;

    private final StringRedisTemplate stringRedisTemplate;

    @Autowired
    public AppController(StringRedisTemplate stringRedisTemplate) {
        this.stringRedisTemplate = stringRedisTemplate;
    }

    @GetMapping(produces = MediaType.TEXT_PLAIN_VALUE)
    public String index() {
        final long count = stringRedisTemplate.boundValueOps("counter").increment(1);

        return "Hello from " + hostname + " (count is " + count + ")";
    }
}
