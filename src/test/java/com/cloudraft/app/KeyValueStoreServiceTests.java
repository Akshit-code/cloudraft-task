package com.example.keyvaluestore.service;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class KeyValueStoreServiceTests {
    private KeyValueStoreService keyValueStoreService;

    @BeforeEach
    void setUp() {
        keyValueStoreService = new KeyValueStoreService();
    }

    @Test
    void testGetValue() {
        String key = "testKey";
        String value = "testValue";
        keyValueStoreService.setValue(key, value);

        Object retrievedValue = keyValueStoreService.getValue(key);

        assertEquals(value, retrievedValue);
    }

    @Test
    void testSetValue() {
        String key = "testKey";
        String value = "testValue";

        keyValueStoreService.setValue(key, value);

        Object retrievedValue = keyValueStoreService.getValue(key);

        assertEquals(value, retrievedValue);
    }

    @Test
    void testSearchKeysWithPrefix() {
        keyValueStoreService.setValue("abc-1", "value1");
        keyValueStoreService.setValue("abc-2", "value2");
        keyValueStoreService.setValue("xyz-1", "value3");
        keyValueStoreService.setValue("xyz-2", "value4");

        Object result = keyValueStoreService.searchKeys("abc", null);

        assertEquals(2, ((Iterable<?>) result).spliterator().getExactSizeIfKnown());
    }

    @Test
    void testSearchKeysWithSuffix() {
        keyValueStoreService.setValue("abc-1", "value1");
        keyValueStoreService.setValue("abc-2", "value2");
        keyValueStoreService.setValue("xyz-1", "value3");
        keyValueStoreService.setValue("xyz-2", "value4");

        Object result = keyValueStoreService.searchKeys(null, "-1");

        assertEquals(2, ((Iterable<?>) result).spliterator().getExactSizeIfKnown());
    }

    @Test
    void testSearchKeysWithPrefixAndSuffix() {
        keyValueStoreService.setValue("abc-1", "value1");
        keyValueStoreService.setValue("abc-2", "value2");
        keyValueStoreService.setValue("xyz-1", "value3");
        keyValueStoreService.setValue("xyz-2", "value4");

        Object result = keyValueStoreService.searchKeys("abc", "-2");

        assertEquals(1, ((Iterable<?>) result).spliterator().getExactSizeIfKnown());
    }
}
