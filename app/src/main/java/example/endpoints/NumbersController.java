package example.endpoints;

import example.dao.Number;
import example.dao.NumberRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class NumbersController {

    private final NumberRepository repository;

    @Autowired
    public NumbersController(NumberRepository repository) {
        this.repository = repository;
    }

    @RequestMapping("/{n}")
    private Number getNumber(@PathVariable long n) {
        return repository.findOne(n);
    }
}
