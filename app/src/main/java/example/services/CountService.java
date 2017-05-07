package example.services;

import com.netflix.hystrix.contrib.javanica.annotation.HystrixCommand;
import com.netflix.hystrix.contrib.javanica.annotation.HystrixProperty;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

@Service
public class CountService {

    private final StringRedisTemplate stringRedisTemplate;

    @Autowired
    public CountService(StringRedisTemplate stringRedisTemplate) {
        this.stringRedisTemplate = stringRedisTemplate;
    }

    @HystrixCommand(fallbackMethod = "fallbackCount", commandProperties = {
        @HystrixProperty(name = "execution.isolation.thread.timeoutInMilliseconds", value = "50")
    })
    public long count() {
        return stringRedisTemplate.boundValueOps("counter").increment(1);
    }

    private long fallbackCount() {
        return -1;
    }
}
