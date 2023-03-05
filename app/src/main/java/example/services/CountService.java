package example.services;

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

    public long count() {
        return stringRedisTemplate.boundValueOps("counter").increment(1);
    }

    private long fallbackCount() {
        return -1;
    }
}
