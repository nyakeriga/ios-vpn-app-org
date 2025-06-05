// libbox.c

#include <stdio.h>
#include "libbox.h"

// Dummy implementation for testing
int libbox_start(const char *configJSON) {
    printf("libbox_start called with config: %s\n", configJSON);
    return 0; // Return 0 for success
}

void libbox_stop(void) {
    printf("libbox_stop called\n");
}
