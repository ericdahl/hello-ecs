package example.dao;

import javax.persistence.Entity;
import javax.persistence.Id;

@Entity
public class Number {

    @Id
    private final long n;

    private final boolean prime;

    protected Number() {
        n = 0;
        prime = false;
    }

    public Number(long n, boolean prime) {
        this.n = n;
        this.prime = prime;
    }

    public long getN() {
        return n;
    }

    public boolean isPrime() {
        return prime;
    }
}
