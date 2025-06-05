// libbox.h

#ifndef LIBBOX_H
#define LIBBOX_H

#ifdef __cplusplus
extern "C" {
#endif

// These are the functions you are calling from Swift
int libbox_start(const char *configJSON);
void libbox_stop(void);

#ifdef __cplusplus
}
#endif

#endif // LIBBOX_H
