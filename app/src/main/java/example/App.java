package example;

import ch.qos.logback.access.jetty.RequestLogImpl;
import com.amazonaws.auth.DefaultAWSCredentialsProviderChain;
import com.amazonaws.services.cloudwatch.AmazonCloudWatchAsyncClient;
import com.blacklocus.metrics.CloudWatchReporter;
import com.blacklocus.metrics.CloudWatchReporterBuilder;
import com.codahale.metrics.MetricRegistry;
import example.dao.NumberRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.embedded.EmbeddedServletContainerCustomizer;
import org.springframework.boot.context.embedded.jetty.JettyEmbeddedServletContainerFactory;
import org.springframework.boot.context.embedded.jetty.JettyServerCustomizer;
import org.springframework.cloud.netflix.hystrix.EnableHystrix;
import org.springframework.context.annotation.Bean;

import java.util.concurrent.TimeUnit;

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

    @Bean
    public CommandLineRunner initializeNumber(NumberRepository repository) {
        return (args) -> {
            repository.save(new example.dao.Number(2, true));
        };
    }

    @Bean
    public CloudWatchReporter cloudWatchReporter(MetricRegistry metricRegistry) {
        final AmazonCloudWatchAsyncClient client = new AmazonCloudWatchAsyncClient(new DefaultAWSCredentialsProviderChain());

        // FIXME
        client.setEndpoint("https://monitoring.us-west-2.amazonaws.com");

        final CloudWatchReporter cloudWatchReporter = new CloudWatchReporterBuilder()
                .withRegistry(metricRegistry)
                .withNamespace("hello_ecs")
                .withClient(client)
                .build();

        cloudWatchReporter.start(1, TimeUnit.MINUTES);
        return cloudWatchReporter;
    }
}
