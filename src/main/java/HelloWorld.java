package com.github.ruanbekker.docker_java_springboot_hello_world.springboot.basic;

import org.springframework.boot.*;
import org.springframework.boot.autoconfigure.*;
import org.springframework.web.bind.annotation.*;

@SpringBootApplication
@RestController

public class HelloWorld {

	@RequestMapping("/")
	String home() {
		return "Hello, World!";
	}

	public static void main(String[] args) throws Exception {
		SpringApplication.run(HelloWorld.class, args);
	}

}