package dev.jrfrazier.runnerz.user;

import org.springframework.boot.autoconfigure.amqp.RabbitConnectionDetails;

public record User(
        Integer id,
        String name,
        String email,
        Address address,
        String phone,
        String website,
        Company company
) {

}
