#!/usr/bin/env bash
# i3bar status_command: i3status plus an NVIDIA GPU block inserted after the CPU.
# i3status has no GPU module, so this edits its JSON stream line by line.
i3status | {
    read -r header && echo "$header"   # {"version":1}
    read -r open && echo "$open"       # [
    while read -r line; do
        prefix=""
        [[ $line == ,* ]] && prefix="," && line="${line#,}"
        gpu=$(nvidia-smi --query-gpu=utilization.gpu,temperature.gpu --format=csv,noheader,nounits 2>/dev/null)
        if [[ -n $gpu ]]; then
            IFS=', ' read -r usage temp <<< "$gpu"
            line=$(jq -c --arg t "GPU ${usage}% ${temp}°C" \
                '(map(.name) | index("cpu_usage")) as $i
                 | .[:($i // length) + 1] + [{name: "gpu", full_text: $t}] + .[($i // length) + 1:]' <<< "$line")
        fi
        echo "${prefix}${line}"
    done
}
