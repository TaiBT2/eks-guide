package com.example.springbootk8sdemo.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class HomeController {
    
    @GetMapping("/")
    public String home() {
        return "redirect:/users";
    }
    
    @GetMapping("/health")
    public String health() {
        return "Health check endpoint for Kubernetes";
    }
}
