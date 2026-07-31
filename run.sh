#!/bin/bash

shopt -s extglob

ROMS_DIR="${1%"/"}"
BEZELS_DIR="${2%"/"}"
RA_CONFIG_DIR="${3%"/"}/config"
SYS="${4%"/"}"

if [ ! -d "$ROMS_DIR" ]; then
    echo "$ROMS_DIR/ is not a directory" >&2
    exit 1
fi

if [[ "$SYS" != "" ]] && [ ! -d "$ROMS_DIR/$SYS" ]; then
    echo "$ROMS_DIR/$SYS/ is not a directory" >&2
    exit 1
fi

if [ ! -d "$BEZELS_DIR" ]; then
    echo "$BEZELS_DIR/ is not a directory" >&2
    exit 1
fi

BEZELS_DIR="$(realpath "$BEZELS_DIR")"

if [ ! -d "$RA_CONFIG_DIR" ]; then
    echo "$RA_CONFIG_DIR/ is not a directory" >&2
    exit 1
fi

RA_CONFIG_DIR="$(realpath "$RA_CONFIG_DIR")"

TAGS_ORDER=("world" "usa" "us" "europe" "en")

write_overlay_to_configs() {
    local l_bezels_cnf_dir="$1"
    local l_overlay_path="$2"
    local l_game="$3"
    local l_overlay_search_pattern="^input_overlay = .*$"
    local l_overlay_string="input_overlay = \"$l_overlay_path\""

    if [ -f "$l_overlay_path" ]; then
        for emu_dir in "$l_bezels_cnf_dir/"*; do
            if [ -d "$emu_dir" ]; then
                emu="$(basename "$emu_dir")"
                ra_emu_dir="$RA_CONFIG_DIR/$emu"

                if [[ "$l_game" == "" ]]; then
                    cnf_file="$ra_emu_dir/$emu.cfg"
                else
                    cnf_file="$ra_emu_dir/$l_game.cfg"
                fi

                if [ ! -d "$ra_emu_dir" ]; then
                    echo "creating: $ra_emu_dir"
                    mkdir "$ra_emu_dir"
                fi

                echo "processing: $cnf_file"

                grep -q "$l_overlay_search_pattern" "$cnf_file" 2>/dev/null \
                    && sed -i "s|$l_overlay_search_pattern|$l_overlay_string|g" "$cnf_file" \
                    || echo "$l_overlay_string" >> "$cnf_file"
            fi
        done
    fi
}

prefix="bezelproject-"
suffix="-master"

for bezels_dir in "$BEZELS_DIR/$prefix"*"$suffix"; do
    overlay_dir="$bezels_dir/retroarch/overlay"
    config_dir="$bezels_dir/retroarch/config"

    if [ -d "$overlay_dir" ] && [ -d "$config_dir" ]; then
        bezels_sys="$(basename "$bezels_dir")"
        bezels_sys="${bezels_sys#"$prefix"}"
        bezels_sys="${bezels_sys%"$suffix"}"
        bezels_sys_lc="${bezels_sys,,}"

        if [[ "$SYS" == "$bezels_sys_lc" ]] || [[ "$SYS" == "" ]]; then
            sys_dir="$ROMS_DIR/$bezels_sys_lc"

            if [ -d "$sys_dir" ]; then
                for overlay in "$overlay_dir/"*".cfg"; do
                    write_overlay_to_configs "$config_dir" "$overlay"
                done

                game_bezels_dir="$overlay_dir/GameBezels/$bezels_sys"

                if [ -d "$game_bezels_dir" ]; then
                    find "$sys_dir/"* -not \( -path "$sys_dir/media/*" -prune \) -type f -print0 2>/dev/null | while IFS= read -r -d '' file; do
                        game_basename="$(basename "$file")"
                        game_basename_wo_ext="${game_basename%"."*}"
                        game_pattern="${game_basename_wo_ext%%+("["*"]"*(" ")|"("*")"*(" "))}"
                        game_pattern="${game_pattern%%+(" ")}"

                        overlays=()

                        for overlay in "$game_bezels_dir/$game_pattern"*(" ")*("["*"]"*(" ")|"("*")"*(" "))".cfg"; do
                            if [ -f "$overlay" ]; then
                                overlays+=("$overlay")
                            fi
                        done

                        count="${#overlays[@]}"

                        if [ "$count" -gt 0 ]; then
                            best_overlay="${overlays}"

                            if [ "$count" -gt 1 ]; then
                                best_good=""
                                best_beta=""

                                for tag in "${TAGS_ORDER[@]}"; do
                                    for overlay in "${overlays[@]}"; do
                                        overlay_basename="$(basename "$overlay")"
                                        overlay_basename_lc="${overlay_basename,,}"

                                        if [[ "$overlay_basename_lc" == *"$tag"* ]]; then
                                            if [[ "$overlay_basename_lc" != *"beta"* ]]; then
                                                best_good="$overlay"

                                                break 2
                                            elif [[ "$best_beta" == "" ]]; then
                                                best_beta="$overlay"
                                            fi
                                        fi
                                    done
                                done

                                if [[ "$best_good" != "" ]]; then
                                    best_overlay="$best_good"
                                elif [[ "$best_beta" != "" ]]; then
                                    best_overlay="$best_beta"
                                fi
                            fi

                            write_overlay_to_configs "$config_dir" "$best_overlay" "$game_basename_wo_ext"
                        fi
                    done
                fi
            fi
        fi
    fi
done
