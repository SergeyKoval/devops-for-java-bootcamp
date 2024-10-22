package com.example.springboot;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class AppController {
  @Value("${DEVOPS}")
  private String name;

  @GetMapping("/")
  public String index() {
    return "Greetings from Spring Boot!!!!!";
  }

  @GetMapping("/endpoint1")
  public String endpoint1() {
    return "Endpoint 1";
  }

  @GetMapping("/hello")
  public String endpoint2() {
    return "Hello %s".formatted(name);
  }
}
