#ifndef EXAMPLE_H
#define EXAMPLE_H

namespace facebook {
    namespace jsi {
        class Runtime;
    }
}


namespace gizwits_c_sdk {
    void install(facebook::jsi::Runtime &jsiRuntime);
}

#endif /* EXAMPLE_H */
