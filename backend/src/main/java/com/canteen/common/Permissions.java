package com.canteen.common;

import java.util.List;

/**
 * 权限点常量。管理员角色 -> 权限集合的映射集中在这里，便于扩展。
 */
public final class Permissions {

    public static final String DASHBOARD_READ = "dashboard.read";
    public static final String DISHES_READ = "dishes.read";
    public static final String DISHES_CREATE = "dishes.create";
    public static final String DISHES_UPDATE = "dishes.update";
    public static final String DISHES_DELETE = "dishes.delete";
    public static final String CATEGORIES_MANAGE = "categories.manage";
    public static final String INVENTORY_MANAGE = "inventory.manage";
    public static final String ORDERS_READ = "orders.read";
    public static final String ORDERS_UPDATE = "orders.update";
    public static final String USERS_READ = "users.read";
    public static final String USERS_DISABLE = "users.disable";
    public static final String BANNERS_MANAGE = "banners.manage";
    public static final String NUTRITION_MANAGE = "nutrition.manage";
    public static final String ADMINS_MANAGE = "admins.manage";
    public static final String SETTINGS_MANAGE = "settings.manage";

    public static final List<String> SUPER_ADMIN = List.of(
            DASHBOARD_READ, DISHES_READ, DISHES_CREATE, DISHES_UPDATE, DISHES_DELETE,
            CATEGORIES_MANAGE, INVENTORY_MANAGE, ORDERS_READ, ORDERS_UPDATE,
            USERS_READ, USERS_DISABLE, BANNERS_MANAGE, NUTRITION_MANAGE,
            ADMINS_MANAGE, SETTINGS_MANAGE);

    public static final List<String> OPERATOR = List.of(
            DASHBOARD_READ, DISHES_READ, DISHES_CREATE, DISHES_UPDATE,
            CATEGORIES_MANAGE, INVENTORY_MANAGE, ORDERS_READ, ORDERS_UPDATE,
            BANNERS_MANAGE, NUTRITION_MANAGE, USERS_READ);

    public static final List<String> NUTRITION_ADMIN = List.of(
            DASHBOARD_READ, DISHES_READ, DISHES_UPDATE, NUTRITION_MANAGE, BANNERS_MANAGE);

    private Permissions() {
    }

    public static List<String> ofRole(String roleCode) {
        if (roleCode == null) {
            return List.of();
        }
        return switch (roleCode) {
            case "SUPER_ADMIN" -> SUPER_ADMIN;
            case "OPERATOR" -> OPERATOR;
            case "NUTRITION_ADMIN" -> NUTRITION_ADMIN;
            default -> List.of();
        };
    }
}
