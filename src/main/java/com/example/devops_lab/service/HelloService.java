package com.example.devops_lab.service;

import org.springframework.stereotype.Service;

@Service
public class HelloService {

    public String getHello() {
        return "hello";
    }
}
