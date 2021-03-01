package com.ruanbekker.cargarage;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

@SpringBootApplication
@EnableJpaAuditing
public class CarGarageApplication {

	public static void main(String[] args) {
		SpringApplication.run(CarGarageApplication.class, args);
	}
}