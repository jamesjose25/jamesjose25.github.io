# Building

At this point you should have fully installed all the prerequisite software, created and loaded your RTC workspace correctly, and created a `build_env` script and used it to to create the `sandboxrc` file. From this point on, I will assume that you are working in a terminal that has run already `build_env` script correctly.

The ACE server build can be broken down into three or four major components: `messages`, `IntegrationAPI`, `webui` (v10 and earlier), and the main `WMB` (aka server core) build:

* The `messages` component compiles our multi-lingual user facing message catalogues from an internal cross-platform format to a number of platform specific files used by the `IntegrationAPI` and the main server build.
* The `IntegrationAPI` component contains the public Java API that can be used to interact and administer the server runtime. It is used by customers, by the toolkit, and internally by the server runtime.
* The `webui` component contains the administation web user interface. This component is only present at v10 and earlier as it has been replaced by Node.js modules at v11 which are managed externally.
* The `WMB` component builds the server runtime itself and forms the vast bulk of a localbuild.

Each component has its own separate build step. The `WMB` build depends on both the `messages` build and the `IntegrationAPI` build, and the `IntegrationAPI` build depends on the `messages` build. This means that if you make changes or accept changes into the `messages` or `IntegrationAPI` components then you will need to start rebuilding from the appropriate step rather than just rebuilding the `WMB` component.
