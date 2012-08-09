#include "callback_holder.h"
#include "lb.h"

/*
 * remove pointers to null callbacks
 */

void CallbackHolder::clean(lua_State *L) {
    GSList *invalid = NULL;
    GSList *iter = NULL;

    for (iter=callback_refs; iter; iter=iter->next) {
        lb_weak_deref(L, GPOINTER_TO_INT(iter->data));
        if (lua_isnil(L, -1)) {
            invalid = g_slist_append(invalid, iter->data);
        }
        lua_pop(L, 1);
    }

    for (iter=invalid; iter; iter=iter->next) {
        callback_refs = g_slist_remove(callback_refs, iter->data);
    }

}

CallbackHolder::CallbackHolder() {
    callback_refs = NULL;
}

CallbackHolder::~CallbackHolder() {
    g_slist_free(callback_refs);
}

int CallbackHolder::add_callback(lua_State *L) {
    int ref = lb_weak_ref(L);
    callback_refs = g_slist_append(callback_refs, GINT_TO_POINTER(ref));
    clean(L);
    lua_pushnumber(L, ref);
    return 1;
}

void CallbackHolder::remove_callback(lua_State* L) {
    int ref = lua_tonumber(L, -1);
    lb_weak_unref(L, ref);
    callback_refs = g_slist_remove(callback_refs, GINT_TO_POINTER(ref+1));
}

void CallbackHolder::invoke_callbacks(lua_State *L, int nargs) {
    if (!callback_refs) return;
    GSList *iter = NULL;

    clean(L);

    for (iter=callback_refs; iter; iter=iter->next) {
        lb_weak_deref(L, GPOINTER_TO_INT(iter->data));
        lua_insert(L, -(nargs+1));
        if (lua_pcall(L, nargs, 0, 0) != 0)
            lua_error(L);
    }
}

void CallbackHolder::print_num_callbacks(char* title) {
    printf("%s\n", title);
    GSList *iter = NULL;
    int count = 0;
    for (iter=callback_refs; iter; iter=iter->next) {
        count++;
        printf("%p\n", iter);
        if (count>10) break;
    }
}
