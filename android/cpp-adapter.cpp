#include <jni.h>
#include <sys/types.h>
#include "gizwits_c_sdk.h"
#include "pthread.h"
#include <jsi/jsi.h>
#include <android/log.h>

using namespace facebook::jsi;
using namespace std;

JavaVM *java_vm;
jclass java_class;
jobject java_object;

jclass java_class_device;
jobject java_object_device;

/**
 * A simple callback function that allows us to detach current JNI Environment
 * when the thread
 * See https://stackoverflow.com/a/30026231 for detailed explanation
 */


static jstring string2jstring(JNIEnv *env, const string &str) {
    return (*env).NewStringUTF(str.c_str());
}
void DeferThreadDetach(JNIEnv *env) {
    static pthread_key_t thread_key;

    // Set up a Thread Specific Data key, and a callback that
    // will be executed when a thread is destroyed.
    // This is only done once, across all threads, and the value
    // associated with the key for any given thread will initially
    // be NULL.
    static auto run_once = [] {
        const auto err = pthread_key_create(&thread_key, [](void *ts_env) {
            if (ts_env) {
                java_vm->DetachCurrentThread();
            }
        });
        if (err) {
            // Failed to create TSD key. Throw an exception if you want to.
        }
        return 0;
    }();

    // For the callback to actually be executed when a thread exits
    // we need to associate a non-NULL value with the key on that thread.
    // We can use the JNIEnv* as that value.
    const auto ts_env = pthread_getspecific(thread_key);
    if (!ts_env) {
        if (pthread_setspecific(thread_key, env)) {
            // Failed to set thread-specific value for key. Throw an exception if you want to.
        }
    }
}

/**
 * Get a JNIEnv* valid for this thread, regardless of whether
 * we're on a native thread or a Java thread.
 * If the calling thread is not currently attached to the JVM
 * it will be attached, and then automatically detached when the
 * thread is destroyed.
 *
 * See https://stackoverflow.com/a/30026231 for detailed explanation
 */
JNIEnv *GetJniEnv() {
    JNIEnv *env = nullptr;
    // We still call GetEnv first to detect if the thread already
    // is attached. This is done to avoid setting up a DetachCurrentThread
    // call on a Java thread.

    // g_vm is a global.
    auto get_env_result = java_vm->GetEnv((void **) &env, JNI_VERSION_1_6);
    if (get_env_result == JNI_EDETACHED) {
        if (java_vm->AttachCurrentThread(&env, NULL) == JNI_OK) {
            DeferThreadDetach(env);
        } else {
            // Failed to attach thread. Throw an exception if you want to.
        }
    } else if (get_env_result == JNI_EVERSION) {
        // Unsupported JNI version. Throw an exception if you want to.
    }
    return env;
}

void install(facebook::jsi::Runtime &jsiRuntime) {

    auto getVersion = Function::createFromHostFunction(jsiRuntime,
                                                          PropNameID::forAscii(jsiRuntime,
                                                                               "getVersion"),
                                                          0,
                                                          [](Runtime &runtime,
                                                             const Value &thisValue,
                                                             const Value *arguments,
                                                             size_t count) -> Value {

                                                              JNIEnv *jniEnv = GetJniEnv();

                                                              java_class = jniEnv->GetObjectClass(
                                                                      java_object);
                                                              jmethodID getVersion_c = jniEnv->GetMethodID(
                                                                      java_class, "getVersion_c",
                                                                      "()Ljava/lang/String;");
                                                              jobject result = jniEnv->CallObjectMethod(
                                                                      java_object, getVersion_c);
                                                              const char *str = jniEnv->GetStringUTFChars(
                                                                      (jstring) result, NULL);

                                                              return Value(runtime,
                                                                           String::createFromUtf8(
                                                                                   runtime, str));

                                                          });

    jsiRuntime.global().setProperty(jsiRuntime, "getVersion", move(getVersion));
}

void installDevice(facebook::jsi::Runtime &jsiRuntime) {

    auto setSubscribe = Function::createFromHostFunction(jsiRuntime,
                                                          PropNameID::forAscii(jsiRuntime,
                                                                               "setSubscribe"),
                                                          0,
                                                          [](Runtime &runtime,
                                                             const Value &thisValue,
                                                             const Value *arguments,
                                                             size_t count) -> Value {

        // 检查参数个数是否正确
          if (count < 5) {
            return Value(false);
        }

        // 检查参数类型是否正确
        if (!arguments[0].isString() || !arguments[1].isString() || !arguments[2].isString() || !arguments[3].isString() || !arguments[4].isBool()) {
            return Value(false);
        }
        JNIEnv *jniEnv = GetJniEnv();

        string mac = arguments[0].getString(
                runtime).utf8(runtime);
        string did = arguments[1].getString(
                runtime).utf8(runtime);
        string productKey = arguments[2].getString(
                runtime).utf8(runtime);
        string productSecret = arguments[3].getString(
                runtime).utf8(runtime);

        bool subscribed = arguments[4].getBool();

        jstring jsmac = string2jstring(jniEnv,mac);
        jstring jsdid = string2jstring(jniEnv,did);
        jstring jsps = string2jstring(jniEnv,productSecret);
        jboolean jsubscribed = (jboolean)subscribed;


        jvalue params[4];
        params[0].l = jsmac;
        params[1].l = jsdid;
        params[2].l = jsps;
        params[3].z = jsubscribed;

        __android_log_print(ANDROID_LOG_DEBUG, "setSubscribe_c", "Function Name: %s", mac.c_str());

        java_class_device = jniEnv->GetObjectClass(
                java_object_device);
        jmethodID setSubscribe_c = jniEnv->GetMethodID(
                java_class_device, "setSubscribe_c",
                "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Z)V");
        jniEnv->CallVoidMethodA(
                java_object_device, setSubscribe_c, params);
        return Value(true);

    });

    jsiRuntime.global().setProperty(jsiRuntime, "setSubscribe", move(setSubscribe));
}

void emitJsi(JNIEnv *env, jobject thiz, jlong jsi, jstring name, jstring data) {
    if (jsi == 0) {
        __android_log_print(ANDROID_LOG_ERROR, "Java_com_gizwitssdk_RNGizwitsRnSdkModule_emitJSI", "Invalid JSI pointer");
        return;
    }

    auto runtime = reinterpret_cast<facebook::jsi::Runtime *>(jsi);

    if (name == nullptr || data == nullptr) {
        __android_log_print(ANDROID_LOG_ERROR, "Java_com_gizwitssdk_RNGizwitsRnSdkModule_emitJSI", "Invalid name or data string");
        return;
    }

    const char *nameChars = env->GetStringUTFChars(name, nullptr);
    const char *dataChars = env->GetStringUTFChars(data, nullptr);

    if (nameChars == nullptr || dataChars == nullptr) {
        __android_log_print(ANDROID_LOG_ERROR, "Java_com_gizwitssdk_RNGizwitsRnSdkModule_emitJSI", "Failed to get name or data string");
        return;
    }

    std::string functionName(nameChars);
    std::string jsonString(dataChars);

    env->ReleaseStringUTFChars(name, nameChars);
    env->ReleaseStringUTFChars(data, dataChars);

    facebook::jsi::Object globalObject = runtime->global();
    facebook::jsi::String functionNameString = facebook::jsi::String::createFromUtf8(*runtime, functionName);
    facebook::jsi::String jsonStringJsi = facebook::jsi::String::createFromUtf8(*runtime, jsonString);

    if (globalObject.hasProperty(*runtime, functionNameString)) {
        facebook::jsi::Value nameFunction = globalObject.getProperty(*runtime, functionNameString);
        if (nameFunction.isObject() && nameFunction.asObject(*runtime).isFunction(*runtime)) {
            facebook::jsi::Function function = nameFunction.asObject(*runtime).asFunction(*runtime);
            function.call(*runtime, jsonStringJsi, 1); // 传递需要的参数
        }
    }
}

extern "C"
JNIEXPORT void JNICALL
Java_com_gizwitssdk_RNGizwitsRnSdkModule_nativeInstall(JNIEnv *env, jobject thiz, jlong jsi) {

    auto runtime = reinterpret_cast<facebook::jsi::Runtime *>(jsi);

    if (runtime) {
        gizwits_c_sdk::install(*runtime);
        install(*runtime);
    }

    env->GetJavaVM(&java_vm);
    java_object = env->NewGlobalRef(thiz);
}

// 安装 device类
extern "C"
JNIEXPORT void JNICALL
Java_com_gizwitssdk_RNGizwitsRnDeviceModule_nativeInstallDevice(JNIEnv *env, jobject thiz, jlong jsi) {

    auto runtime = reinterpret_cast<facebook::jsi::Runtime *>(jsi);

    if (runtime) {
        gizwits_c_sdk::install(*runtime);
        installDevice(*runtime);
    }

    java_object_device = env->NewGlobalRef(thiz);
}

extern "C"
JNIEXPORT void JNICALL
Java_com_gizwitssdk_RNGizwitsRnSdkModule_emitJSI(JNIEnv *env, jobject thiz, jlong jsi, jstring name, jstring data) {

    emitJsi(env, thiz, jsi, name, data);

}

extern "C"
JNIEXPORT void JNICALL
Java_com_gizwitssdk_RNGizwitsRnDeviceModule_emitJSI(JNIEnv *env, jobject thiz, jlong jsi, jstring name, jstring data) {
    emitJsi(env, thiz, jsi, name, data);
}

