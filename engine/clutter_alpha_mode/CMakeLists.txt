add_library( clutteralphamode SHARED clutter_alpha_mode.c )

SET_TARGET_PROPERTIES( clutteralphamode PROPERTIES LINK_FLAGS -lm )

install(TARGETS clutteralphamode LIBRARY DESTINATION lib)
