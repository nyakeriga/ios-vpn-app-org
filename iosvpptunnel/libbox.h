// libbox.h

#ifndef LIBBOX_H
#define LIBBOX_H

#ifdef __cplusplus
extern "C" {
#endif

int libbox_start(const char *configJSON);  // ✅ used by Swift
void libbox_stop(void);                    // ✅ used by Swift

#ifdef __cplusplus
}
#endif

#endif /* LIBBOX_H */
