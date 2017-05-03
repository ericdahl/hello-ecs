package example.endpoints;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class AppController {

    @Value("${HOSTNAME:unknown}")
    private String hostname;

    @GetMapping(produces = MediaType.TEXT_PLAIN_VALUE)
    public String index() {
        return "Hello from " + hostname;
    }
}
