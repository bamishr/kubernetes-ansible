DOWNSTREAM_VERSION="1.1.1"
KEEP_DOWNSTREAM_TMPDIR="${KEEP_DOWNSTREAM_TMPDIR:-''}"


f_log_info()
{
    printf "%s:LOG:INFO: %s\n" "${0}" "${1}\n"
}

f_prep()
{
    f_log_info "${FUNCNAME[0]}"
    # Array of excluded files from downstream build (relative path)
    _file_exclude=(
    )

    # Files to copy downstream (relative repo root dir path)
    _file_manifest=(
        CHANGELOG.rst
        galaxy.yml
        LICENSE
        README.md
        Makefile
        setup.cfg
        .yamllint
    )

    # Directories to recursively copy downstream (relative repo root dir path)
    _dir_manifest=(
        changelogs
        meta
        plugins
        tests
        molecule
    )
  # Temp build dir
    _tmp_dir=$(mktemp -d)
    _build_dir="${_tmp_dir}/ansible_collections/kubernetes/core"
    mkdir -p "${_build_dir}"
}
