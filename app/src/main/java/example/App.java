package example;

import ch.qos.logback.access.jetty.RequestLogImpl;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.embedded.EmbeddedServletContainerCustomizer;
import org.springframework.boot.context.embedded.jetty.JettyEmbeddedServletContainerFactory;
import org.springframework.boot.context.embedded.jetty.JettyServerCustomizer;
import org.springframework.cloud.netflix.hystrix.EnableHystrix;
import org.springframework.context.annotation.Bean;

@SpringBootApplication
@EnableHystrix
public class App {

    public static void main(String[] args) {
        SpringApplication.run(App.class, args);
    }

    @Bean
    public EmbeddedServletContainerCustomizer embeddedServletContainerCustomizer() {
        return customizer -> {
            if (customizer instanceof JettyEmbeddedServletContainerFactory) {
                final JettyEmbeddedServletContainerFactory jettyCustomizer = (JettyEmbeddedServletContainerFactory) customizer;
                jettyCustomizer.addServerCustomizers((JettyServerCustomizer) server -> {
                    final RequestLogImpl requestLog = new RequestLogImpl();
                    requestLog.setResource("/logback-access.xml");
                    requestLog.start();
                    server.setRequestLog(requestLog);
                });
            }
        };
    }
}
