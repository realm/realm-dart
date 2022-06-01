#ifdef __cplusplus
#define RLM_API extern "C" __attribute__((visibility("default")))
#else
#define RLM_API
#endif // __cplusplus

RLM_API const char* realm_dart_get_app_directory_name();