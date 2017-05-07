package example.endpoints;

import example.services.CountService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class AppController {

    @Value("${HOSTNAME:unknown}")
    private String hostname;

    private final CountService counterService;

    @Autowired
    public AppController(CountService counterService) {
        this.counterService = counterService;
    }

    @GetMapping(produces = MediaType.TEXT_PLAIN_VALUE)
    public String index() {
        final long count = counterService.count();

        return "Hello from " + hostname + " (count is " + count + ")";
    }
}
