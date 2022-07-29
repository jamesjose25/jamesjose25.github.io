#!/bin/bash

function usage() {
    echo "Usage: $0 <JDK_ARCHIVE>"
}

if [ -z "$1" ]; then
    usage
    exit 1
fi

if [ "$EUID" -ne 0 ]; then
    echo "Error: This utility must be run as root."
    usage
    exit 1
fi

set -e

JDK_ARCHIVE=$(realpath "$1")
if [ ! -f "${JDK_ARCHIVE}" ]; then
    echo "Error: JDK archive '${JDK_ARCHIVE}' does not exist."
    usage
    exit 1
fi

JDK_TEMP_DIR=$(mktemp -d '/tmp/install_jdk.XXXXXX')
echo "Extracting JDK archive '${JDK_ARCHIVE}' to '${JDK_TEMP_DIR}'"
tar -x -z -C "${JDK_TEMP_DIR}" -f "${JDK_ARCHIVE}"

# Basic sanity check to ensure we've been given a JDK and not a JRE
if [ ! -f "${JDK_TEMP_DIR}/bin/javac" ]; then
    echo "Error: JDK archive '${JDK_ARCHIVE}' did not contain javac"
    rm -rf "${JDK_TEMP_DIR}"
    exit 1
fi

JAVA_VERSION=$("${JDK_TEMP_DIR}/bin/javac" -version 2>&1 | cut -d ' ' -f 2)
JAVA_U_VERSION=$(echo "${JAVA_VERSION}" | cut -d '_' -f 2)
IBM_JAVA_V=$(echo "${JAVA_VERSION}" | sed -e 's/^1\.\([0-9]*\)\.\([0-9]*\)_[0-9]*$/\1/')
IBM_JAVA_R=$(echo "${JAVA_VERSION}" | sed -e 's/^1\.\([0-9]*\)\.\([0-9]*\)_[0-9]*$/\2/')
IBM_JAVA_M=$("${JDK_TEMP_DIR}/bin/java" -version 2>&1 | head -n 2 | tail -n 1 | grep -o -e 'SR[0-9]*' | sed -e 's/SR//')
IBM_JAVA_F=$("${JDK_TEMP_DIR}/bin/java" -version 2>&1 | head -n 2 | tail -n 1 | grep -o -e 'FP[0-9]*' | sed -e 's/FP//')

IBM_JAVA_VRMF="${IBM_JAVA_V}.${IBM_JAVA_R}.${IBM_JAVA_M}.${IBM_JAVA_F}"
echo "Extracted JDK version is ${IBM_JAVA_VRMF} (${JAVA_VERSION})"

if [[ ! "${JAVA_VERSION}" =~ ^1\. ]]; then
    echo "Error: JVM version is not of the form 1.x"
    rm -rf "${JDK_TEMP_DIR}"
    exit 1
fi

INSTALL_LOCATION="/opt/ibm/java/${IBM_JAVA_VRMF}"

if [ -e "${INSTALL_LOCATION}" ]; then
    echo "Error: JVM install location '${INSTALL_LOCATION}' already exists"
    rm -rf "${JDK_TEMP_DIR}"
    exit 1
fi

echo "Installing JDK ${IBM_JAVA_VRMF} into ${INSTALL_LOCATION}"
mv "${JDK_TEMP_DIR}" "${INSTALL_LOCATION}"
chmod -R 'g+rx,o+rx' "${INSTALL_LOCATION}"

if [ ! -f "${INSTALL_LOCATION}/Info.plist" ]; then
    echo "WARNING: The JDK did not come with a Info.plist file, one will be generated but it may not be correct."
    echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
        <key>CFBundleDevelopmentRegion</key>
        <string>English</string>
        <key>CFBundleExecutable</key>
        <string>libjli.dylib</string>
        <key>CFBundleGetInfoString</key>
        <string>Java SE ${JAVA_VERSION}</string>
        <key>CFBundleIdentifier</key>
        <string>com.oracle.java.${IBM_JAVA_V}u${JAVA_U_VERSION}.jdk</string>
        <key>CFBundleInfoDictionaryVersion</key>
        <string>7.0</string>
        <key>CFBundleName</key>
        <string>Java SE ${IBM_JAVA_V}</string>
        <key>CFBundlePackageType</key>
        <string>BNDL</string>
        <key>CFBundleShortVersionString</key>
        <string>1.0</string>
        <key>CFBundleSignature</key>
        <string>????</string>
        <key>CFBundleVersion</key>
        <string>${JAVA_VERSION}</string>
        <key>JavaVM</key>
        <dict>
                <key>JVMCapabilities</key>
                <array>
                        <string>CommandLine</string>
                </array>
                <key>JVMMinimumFrameworkVersion</key>
                <string>13.2.9</string>
                <key>JVMMinimumSystemVersion</key>
                <string>10.6.0</string>
                <key>JVMPlatformVersion</key>
                <string>1.8</string>
                <key>JVMVendor</key>
                <string>Oracle Corporation</string>
                <key>JVMVersion</key>
                <string>${JAVA_VERSION}</string>
        </dict>
</dict>
</plist>" > "${INSTALL_LOCATION}/Info.plist"
    chmod a+rx "${INSTALL_LOCATION}/Info.plist"
fi

echo "Registering JDK with the system"
SYSTEM_JDK_LOCATION="/Library/Java/JavaVirtualMachines/jdk${JAVA_VERSION}.jdk"

mkdir -p "${SYSTEM_JDK_LOCATION}/Contents/MacOS"
ln -s "${INSTALL_LOCATION}/Info.plist" "${SYSTEM_JDK_LOCATION}/Contents/Info.plist"
ln -s "${INSTALL_LOCATION}/" "${SYSTEM_JDK_LOCATION}/Contents/Home"
ln -s '../Home/jre/lib/jli/libjli.dylib' "${SYSTEM_JDK_LOCATION}/Contents/MacOS/libjli.dylib"

echo "Modifying JDK Info.plist so that it advertises its capabilities correctly"
sed -e 's/<string>CommandLine<\/string>/<string>CommandLine<\/string><string>JNI<\/string><string>BundledApp<\/string><string>WebStart<\/string><string>Applets<\/string>/' -i '.bak' "${INSTALL_LOCATION}/Info.plist"

echo "Testing that the registration was correct"
SYSTEM_JAVA_HOME=$(/usr/libexec/java_home --version "${JAVA_VERSION}")
if [  "$?" -ne "0" ]; then
    echo "WARNING: System registration test failed! /usr/libexec/java_home failed to find a JVM with version ${JAVA_VERSION}"
    exit 1
elif [ $(realpath "${SYSTEM_JAVA_HOME}") != "${INSTALL_LOCATION}" ]; then
    echo "WARNING: System registration test failed! The JAVA_HOME returned by the system (${SYSTEM_JAVA_HOME}) does not resolve to the install location (${INSTALL_LOCATION}) but instead resolves to '$(realpath "${SYSTEM_JAVA_LOCATION}")'"
    exit 1
else
    echo "Successfully installed Java JDK ${IBM_JAVA_VRMF} (${JAVA_VERSION})"
    exit 0
fi