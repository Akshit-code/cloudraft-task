package com.example.keyvaluestore.service;

import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class KeyValueStoreService {
    private final Map<String, Object> keyValueStore;

    public KeyValueStoreService() {
        this.keyValueStore = new HashMap<>();
    }

    public Object getValue(String key) {
        return keyValueStore.get(key);
    }

    public void setValue(String key, Object value) {
        keyValueStore.put(key, value);
    }

    public Object searchKeys(String prefix, String suffix) {
        if (prefix != null && suffix != null) {
            return keyValueStore.keySet().stream()
                    .filter(k -> k.startsWith(prefix) && k.endsWith(suffix))
                    .collect(Collectors.toList());
        } else if (prefix != null) {
            return keyValueStore.keySet().stream()
                    .filter(k -> k.startsWith(prefix))
                    .collect(Collectors.toList());
        } else if (suffix != null) {
            return keyValueStore.keySet().stream()
                    .filter(k -> k.endsWith(suffix))
                    .collect(Collectors.toList());
        } else {
            // No prefix or suffix provided
            return null;
        }
    }
}
