pkg_name=metricbeat
pkg_origin=devoptimist
pkg_version="6.3.1"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=("Apache-2.0")
pkg_deps=(core/glibc)
pkg_build_deps=(core/go core/git core/make core/gcc core/virtualenv)
pkg_bin_dirs=(bin)
pkg_svc_user="root"
pkg_binds_optional=(
  [kibana]="port"
  [elasticsearch]="http-port"
  [logstash]="port"
)
pkg_description="Lightweight shipper for system metrics"
pkg_upstream_url="https://www.elastic.co/products/beats/metricbeat"

do_download() {
  GOPATH=$(dirname "${HAB_CACHE_SRC_PATH}")
  echo "HAB_CACHE_SRC_PATH is ${HAB_CACHE_SRC_PATH}"
  export GOPATH
  echo "GOPATH is ${GOPATH}"
  build_line "Fetching Go sources."
  go get github.com/elastic/beats/metricbeat
  pushd "${HAB_CACHE_SRC_PATH}/github.com/elastic/beats/metricbeat" > /dev/null
  git checkout "v${pkg_version}"
  popd > /dev/null
}

do_unpack() {
  return 0
}

do_build() {
  pushd "${HAB_CACHE_SRC_PATH}/github.com/elastic/beats/metricbeat" > /dev/null
  make
  make update
  popd > /dev/null
}

do_install() {
  mkdir -p "${pkg_prefix}/static"
  install -D "${HAB_CACHE_SRC_PATH}/github.com/elastic/beats/metricbeat/${pkg_name}" "${pkg_prefix}/bin/${pkg_name}"
  install -D "${HAB_CACHE_SRC_PATH}/github.com/elastic/beats/metricbeat/fields.yml" "${pkg_prefix}/config/fields.yml"
  chown ${pkg_svc_user}:hab -R "${pkg_prefix}/config"
  cp -r "${HAB_CACHE_SRC_PATH}/github.com/elastic/beats/metricbeat/_meta/kibana" "${pkg_prefix}/static"
}
