// libbox.c
#include "libbox.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "singbox/singbox.h"  // Path depends on how you added the repo

static struct sb_context *ctx = NULL;

int libbox_start(const char *configJSON) {
    if (ctx != NULL) {
        fprintf(stderr, "Sing-box already running.\n");
        return -1;
    }

    struct sb_options options;
    memset(&options, 0, sizeof(options));
    options.config_data = configJSON;

    ctx = sb_start(&options);
    if (ctx == NULL) {
        fprintf(stderr, "Failed to start sing-box engine.\n");
        return -2;
    }

    return 0;
}

void libbox_stop(void) {
    if (ctx != NULL) {
        sb_stop(ctx);
        ctx = NULL;
    }
}
