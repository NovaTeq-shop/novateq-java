#!/bin/bash
JAVA_8="/opt/java/8/bin/java"
JAVA_11="/opt/java/11/bin/java"
JAVA_17="/opt/java/17/bin/java"
JAVA_21="/opt/java/21/bin/java"
JAVA_24="/opt/java/24/bin/java"

select_java() {
    local dir="/home/container"
    if [ -f "$dir/unix_args.txt" ]; then
        local args=$(cat "$dir/unix_args.txt" 2>/dev/null)
        if echo "$args" | grep -q "UseCompactObjectHeaders\|UseZGC\|ZGenerational"; then
            echo "[NovaTeq] Java 24 flags → Java 24" >&2; echo "$JAVA_24"; return
        fi
        echo "[NovaTeq] Forge → Java 17" >&2; echo "$JAVA_17"; return
    fi
    if [ -f "$dir/fabric-server-launch.jar" ]; then
        echo "[NovaTeq] Fabric → Java 21" >&2; echo "$JAVA_21"; return
    fi
    local mc_ver="${MC_VERSION:-${VANILLA_VERSION:-}}"
    [ -f "$dir/version.json" ] && mc_ver=$(jq -r '.id // .name' "$dir/version.json" 2>/dev/null)
    local minor=$(echo "$mc_ver" | grep -oP '1\.\K[0-9]+' | head -1)
    if [ -n "$minor" ]; then
        if [ "$minor" -ge 21 ] 2>/dev/null; then echo "[NovaTeq] 1.21+ → Java 21" >&2; echo "$JAVA_21"
        elif [ "$minor" -ge 17 ] 2>/dev/null; then echo "[NovaTeq] 1.17-1.20 → Java 17" >&2; echo "$JAVA_17"
        elif [ "$minor" -ge 12 ] 2>/dev/null; then echo "[NovaTeq] 1.12+ → Java 11" >&2; echo "$JAVA_11"
        else echo "[NovaTeq] legacy → Java 8" >&2; echo "$JAVA_8"; fi
    else
        echo "[NovaTeq] fallback → Java 21" >&2; echo "$JAVA_21"
    fi
}
JAVA_BIN=$(select_java)
exec "$JAVA_BIN" "$@"
