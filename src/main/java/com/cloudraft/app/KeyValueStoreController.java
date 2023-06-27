package com.example.keyvaluestore.controller;

import com.example.keyvaluestore.model.KeyValue;
import com.example.keyvaluestore.service.KeyValueStoreService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
public class KeyValueStoreController {
    private final KeyValueStoreService keyValueStoreService;

    @Autowired
    public KeyValueStoreController(KeyValueStoreService keyValueStoreService) {
        this.keyValueStoreService = keyValueStoreService;
    }

    @GetMapping("/get/{key}")
    public ResponseEntity<Object> getValue(@PathVariable("key") String key) {
        Object value = keyValueStoreService.getValue(key);
        if (value != null) {
            return ResponseEntity.ok(value);
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping("/set")
    public ResponseEntity<String> setValue(@RequestBody KeyValue keyValue) {
        keyValueStoreService.setValue(keyValue.getKey(), keyValue.getValue());
        return ResponseEntity.status(HttpStatus.CREATED).build();
    }

    @GetMapping("/search")
    public ResponseEntity<Object> searchKeys(@RequestParam(value = "prefix", required = false) String prefix,
                                             @RequestParam(value = "suffix", required = false) String suffix) {
        Object result = keyValueStoreService.searchKeys(prefix, suffix);
        if (result != null) {
            return ResponseEntity.ok(result);
        } else {
            return ResponseEntity.notFound().build();
        }
    }
}
