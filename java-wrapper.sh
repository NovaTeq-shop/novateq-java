#!/bin/bash
JAVA_8="/opt/java/8/bin/java"
JAVA_11="/opt/java/11/bin/java"
JAVA_17="/opt/java/17/bin/java"
JAVA_21="/opt/java/21/bin/java"
JAVA_24="/opt/java/24/bin/java"
JAVA_25="/opt/java/25/bin/java"

get_mc_minor() {
    local ver="$1"
    echo "$ver" | grep -oP '1\.\K[0-9]+' | head -1
}

select_java() {
    local dir="/home/container"

    # --- FORGE / NEOFORGE ---
    if [ -f "$dir/unix_args.txt" ]; then
        local args=$(cat "$dir/unix_args.txt" 2>/dev/null)
        if echo "$args" | grep -q "UseCompactObjectHeaders\|UseZGC\|ZGenerational"; then
            echo "[NovaTeq] Java 24+ flags → Java 24" >&2; echo "$JAVA_24"; return
        fi
        local shim_ver=$(ls "$dir"/forge-*-shim.jar 2>/dev/null | grep -oP 'forge-\K[0-9]+' | head -1)
        if [ -n "$shim_ver" ] && [ "$shim_ver" -ge 26 ] 2>/dev/null; then
            echo "[NovaTeq] Forge 26+ → Java 25" >&2; echo "$JAVA_25"; return
        fi
        local forge_mc=$(ls "$dir"/forge-*.jar 2>/dev/null | grep -v shim | grep -oP 'forge-1\.\K[0-9]+' | head -1)
        if [ -n "$forge_mc" ] && [ "$forge_mc" -ge 20 ] 2>/dev/null; then
            echo "[NovaTeq] Forge 1.20+ → Java 21" >&2; echo "$JAVA_21"; return
        elif [ -n "$forge_mc" ] && [ "$forge_mc" -ge 17 ] 2>/dev/null; then
            echo "[NovaTeq] Forge 1.17-1.19 → Java 17" >&2; echo "$JAVA_17"; return
        fi
        echo "[NovaTeq] Forge fallback → Java 21" >&2; echo "$JAVA_21"; return
    fi

    # --- FABRIC / QUILT ---
    if [ -f "$dir/fabric-server-launch.jar" ] || [ -f "$dir/quilt-server-launch.jar" ]; then
        # Lees MC versie uit version.json of env variabele
        local mc_ver=""
        [ -f "$dir/version.json" ] && mc_ver=$(jq -r '.id // .name' "$dir/version.json" 2>/dev/null)
        [ -z "$mc_ver" ] && mc_ver="${MC_VERSION:-${VANILLA_VERSION:-}}"
        local minor=$(get_mc_minor "$mc_ver")
        if [ -n "$minor" ] && [ "$minor" -ge 25 ] 2>/dev/null; then
            echo "[NovaTeq] Fabric MC 1.25+ → Java 25" >&2; echo "$JAVA_25"; return
        elif [ -n "$minor" ] && [ "$minor" -ge 21 ] 2>/dev/null; then
            echo "[NovaTeq] Fabric MC 1.21+ → Java 21" >&2; echo "$JAVA_21"; return
        elif [ -n "$minor" ] && [ "$minor" -ge 17 ] 2>/dev/null; then
            echo "[NovaTeq] Fabric MC 1.17-1.20 → Java 17" >&2; echo "$JAVA_17"; return
        fi
        # Geen versie info → check server jar class version
        if [ -f "$dir/server.jar" ]; then
            local class_ver=$(unzip -p "$dir/server.jar" "net/minecraft/bundler/Main.class" 2>/dev/null | xxd | head -1 | grep -oP '0034 \K[0-9a-f]+' | head -1)
            # class 69 = Java 25, 68 = Java 24, 65 = Java 21
        fi
        echo "[NovaTeq] Fabric fallback → Java 25" >&2; echo "$JAVA_25"; return
    fi

    # --- VANILLA / PAPER / PURPUR ---
    local mc_ver="${MC_VERSION:-${VANILLA_VERSION:-}}"
    [ -f "$dir/version.json" ] && mc_ver=$(jq -r '.id // .name' "$dir/version.json" 2>/dev/null)
    local minor=$(get_mc_minor "$mc_ver")
    if [ -n "$minor" ]; then
        if [ "$minor" -ge 25 ] 2>/dev/null; then echo "[NovaTeq] 1.25+ → Java 25" >&2; echo "$JAVA_25"
        elif [ "$minor" -ge 21 ] 2>/dev/null; then echo "[NovaTeq] 1.21+ → Java 21" >&2; echo "$JAVA_21"
        elif [ "$minor" -ge 17 ] 2>/dev/null; then echo "[NovaTeq] 1.17-1.20 → Java 17" >&2; echo "$JAVA_17"
        elif [ "$minor" -ge 12 ] 2>/dev/null; then echo "[NovaTeq] 1.12+ → Java 11" >&2; echo "$JAVA_11"
        else echo "[NovaTeq] legacy → Java 8" >&2; echo "$JAVA_8"; fi
    else
        echo "[NovaTeq] fallback → Java 25" >&2; echo "$JAVA_25"
    fi
}
JAVA_BIN=$(select_java)
exec "$JAVA_BIN" "$@"
