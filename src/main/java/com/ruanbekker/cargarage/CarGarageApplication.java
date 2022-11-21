package com.ruanbekker.cargarage;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@SpringBootApplication
@EnableJpaAuditing
public class CarGarageApplication {

	private static Logger log = LoggerFactory.getLogger(CarGarageApplication.class);

	public static void main(String[] args) {
		SpringApplication.run(CarGarageApplication.class, args);
		log.info("application is starting with info level logging");
	}
}