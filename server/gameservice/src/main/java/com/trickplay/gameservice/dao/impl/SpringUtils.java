package com.trickplay.gameservice.dao.impl;

import java.util.List;

import org.springframework.util.CollectionUtils;

public class SpringUtils {
    public static <T> T getFirst(List<T> list) {
        return CollectionUtils.isEmpty(list) ? null : list.get(0);
    }
}
