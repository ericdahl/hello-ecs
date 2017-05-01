package example.dao;

import org.springframework.data.repository.CrudRepository;

public interface NumberRepository extends CrudRepository<Number, Long> {
}
