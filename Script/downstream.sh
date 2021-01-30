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
f_show_help()
{
    printf "Usage: downstream.sh [OPTION]\n"
    printf "\t-s\t\tCreate a temporary downstream release and perform sanity tests.\n"
    printf "\t-i\t\tCreate a temporary downstream release and perform integration tests.\n"
    printf "\t-m\t\tCreate a temporary downstream release and perform molecule tests.\n"
    printf "\t-b\t\tCreate a downstream release and stage for release.\n"
    printf "\t-r\t\tCreate a downstream release and publish release.\n"
f_text_sub()
{
    # Switch FQCN and dependent components
    sed -i.bak "s/community-kubernetes/kubernetes-core/" "${_build_dir}/Makefile"
    sed -i.bak "s/community\/kubernetes/kubernetes\/core/" "${_build_dir}/Makefile"
    sed -i.bak "s/^VERSION\:/VERSION: ${DOWNSTREAM_VERSION}/" "${_build_dir}/Makefile"
    sed -i.bak "s/community.kubernetes/kubernetes.core/" "${_build_dir}/galaxy.yml"
    sed -i.bak "s/name\:.*$/name: core/" "${_build_dir}/galaxy.yml"
    sed -i.bak "s/namespace\:.*$/namespace: kubernetes/" "${_build_dir}/galaxy.yml"
    sed -i.bak "s/^version\:.*$/version: ${DOWNSTREAM_VERSION}/" "${_build_dir}/galaxy.yml"
    find "${_build_dir}" -type f -exec sed -i.bak "s/community\.kubernetes/kubernetes\.core/g" {} \;
    sed -i.bak "s/a\.k\.a\. \`kubernetes\.core\`/formerly known as \`community\.kubernetes\`/" "${_build_dir}/README.md";
    find "${_build_dir}" -type f -name "*.bak" -delete
f_cleanup()
{
    f_log_info "${FUNCNAME[0]}"
    if [[ -n ${KEEP_DOWNSTREAM_TMPDIR} ]]; then
        if [[ -d ${_build_dir} ]]; then
            rm -fr "${_build_dir}"
        fi
    fi
f_copy_collection_to_working_dir()
{
    f_log_info "${FUNCNAME[0]}"
    # Copy the Collection build result into original working dir
    cp "${_build_dir}"/*.tar.gz ./
}
f_common_steps()
{
    f_log_info "${FUNCNAME[0]}"
    f_prep
    f_create_collection_dir_structure
    f_text_sub
}}}}}
# Run the test sanity scanerio
f_test_sanity_option()
{
    f_log_info "${FUNCNAME[0]}"
    f_common_steps
    pushd "${_build_dir}" || return
        f_log_info "SANITY TEST PWD: ${PWD}"
        make test-sanity
    popd || return
    f_cleanup
# Run the test integration
f_test_integration_option()
{
    f_log_info "${FUNCNAME[0]}"
    f_common_steps
    pushd "${_build_dir}" || return
        f_log_info "INTEGRATION TEST WD: ${PWD}"
        make test-integration
    popd || return
    f_cleanup
}
}
# Run the molecule tests
f_test_molecule_option()
{
    f_log_info "${FUNCNAME[0]}"
    f_common_steps
    pushd "${_build_dir}" || return
        f_log_info "MOLECULE TEST WD: ${PWD}"
        make test-molecule
    popd || return
    f_cleanup

# Run the release scanerio
f_release_option()
{
    f_log_info "${FUNCNAME[0]}"
    f_common_steps
    pushd "${_build_dir}" || return
        f_log_info "RELEASE WD: ${PWD}"
        make release
    popd || return
    f_cleanup
}
}
