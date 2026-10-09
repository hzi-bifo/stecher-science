#!/usr/bin/env bash
# Shared environment setup for the stage wrappers.
# The wrapper sets ANALYSIS_ROOT by locating this file before SLURM changes paths.
operon_activate_environment() {
    local requested_env="${OPERON_CONDA_ENV:-$1}"
    if [[ "${OPERON_SKIP_CONDA:-0}" == "1" ]]; then
        return 0
    fi
    local conda_command="${CONDA_EXE:-conda}"
    if ! command -v "$conda_command" >/dev/null 2>&1; then
        echo "Conda is unavailable. Set CONDA_EXE, or activate your environment and set OPERON_SKIP_CONDA=1." >&2
        return 1
    fi
    local conda_hook
    conda_hook="$("$conda_command" shell.bash hook)" || return 1
    eval "$conda_hook" || return 1
    conda activate "$requested_env" || return 1
}
