package com.example.springboot;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class AppController {
  @Value("${DEVOPS}")
  private String name;
  @Autowired
  private AccountRepository accountRepository;

  @GetMapping("/")
  public String index() {
    return "Greetings from Spring Boot!!!!!";
  }

  @GetMapping("/accounts/{id}")
  public String getAccountName(@PathVariable Long id) {
    return "Account %s name: %s".formatted(id, accountRepository.findById(id).map(Account::getName).orElse("missed"));
  }

  @GetMapping("/hello")
  public String endpoint2() {
    return "Hello %s".formatted(name);
  }
}
