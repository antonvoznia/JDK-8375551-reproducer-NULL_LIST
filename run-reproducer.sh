#!/bin/sh
set -euo pipefail

JAVA_HOME_IN_USE="${JAVA_HOME}"
JAVAC_BIN="${JAVA_HOME_IN_USE}/bin/javac"
JAVA_BIN="${JAVA_HOME_IN_USE}/bin/java"
JAR_BIN="${JAVA_HOME_IN_USE}/bin/jar"

REPRO_JAR="repro-main.jar"
RECORD_CONFIG="fs-repro.aotconfig"
AOT_CACHE="fs-repro.aot"



rm -f \
  "Repro.class" \
  "TriggerFsProvider.class" \
  "${REPRO_JAR}" \
  "${RECORD_CONFIG}" \
  "${AOT_CACHE}"

"${JAVAC_BIN}" -J-Xshare:off Reproducer.java TriggerFsProvider.java

"${JAR_BIN}" -J-Xshare:off --create --file "${REPRO_JAR}" --main-class Reproducer -C . TriggerFsProvider.class -C . Reproducer.class

"${JAVA_BIN}" \
  -Djava.nio.file.spi.DefaultFileSystemProvider=TriggerFsProvider \
  -XX:AOTMode=record \
  -XX:AOTConfiguration="${RECORD_CONFIG}" \
  "-Xlog:aot*=debug" \
  -cp "${REPRO_JAR}" \
  Reproducer


"${JAVA_BIN}" \
  -Djava.nio.file.spi.DefaultFileSystemProvider=TriggerFsProvider \
  -XX:AOTMode=create \
  -XX:AOTConfiguration="${RECORD_CONFIG}" \
  -XX:AOTCache="${AOT_CACHE}" \
  "-Xlog:aot*=debug,class+init=info" \
  -cp "${REPRO_JAR}" \
  Reproducer
