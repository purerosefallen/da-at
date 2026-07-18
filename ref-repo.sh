#!/usr/bin/env bash

set -euo pipefail
export LC_ALL=C

usage() {
  printf 'Usage: %s [--immutable] <repo-url> <ref>\n' "${0##*/}" >&2
}

die() {
  printf '%s: %s\n' "${0##*/}" "$*" >&2
  exit 1
}

is_full_hash() {
  [[ "$1" =~ ^[0-9a-fA-F]{40}$ ]] || [[ "$1" =~ ^[0-9a-fA-F]{64}$ ]]
}

is_abbreviated_hash() {
  [[ "$1" =~ ^[0-9a-fA-F]{4,63}$ ]] && ! is_full_hash "$1"
}

normalize_hash() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]'
}

sanitize_component() {
  printf '%s' "$1" |
    sed -E 's/[^A-Za-z0-9._-]+/-/g; s/^-+//; s/-+$//'
}

repository_name() {
  local value path leaf namespace safe_leaf safe_namespace
  value="$1"
  path="$value"

  case "$path" in
    *://*)
      path="${path#*://}"
      path="${path#*/}"
      ;;
    *@*:*)
      path="${path#*:}"
      ;;
  esac

  path="${path%%\?*}"
  path="${path%%\#*}"
  while [[ "$path" == /* ]]; do
    path="${path#/}"
  done
  while [[ "$path" == */ ]]; do
    path="${path%/}"
  done
  path="${path%.git}"

  [[ -n "$path" ]] || die "cannot derive a repository name from '$value'"
  leaf="${path##*/}"
  if [[ "$path" == */* ]]; then
    namespace="${path%/*}"
  else
    namespace="unknown"
  fi
  namespace="${namespace//\//-}"

  safe_leaf="$(sanitize_component "$leaf")"
  safe_namespace="$(sanitize_component "$namespace")"
  [[ -n "$safe_leaf" && -n "$safe_namespace" ]] ||
    die "cannot derive a safe repository name from '$value'"
  printf '%s_%s\n' "$safe_namespace" "$safe_leaf"
}

current_timestamp() {
  TZ=Asia/Shanghai date '+%Y%m%d-%H%M%S'
}

expiration_cutoff() {
  if TZ=Asia/Shanghai date -v-7d '+%Y%m%d-%H%M%S' >/dev/null 2>&1; then
    TZ=Asia/Shanghai date -v-7d '+%Y%m%d-%H%M%S'
  elif TZ=Asia/Shanghai date -d '7 days ago' '+%Y%m%d-%H%M%S' >/dev/null 2>&1; then
    TZ=Asia/Shanghai date -d '7 days ago' '+%Y%m%d-%H%M%S'
  else
    die 'cannot calculate the seven-day expiration cutoff with this date command'
  fi
}

cleanup_expired() {
  local cutoff candidate base timestamp remainder last_used
  cutoff="$(expiration_cutoff)"

  for candidate in "$CACHE_ROOT"/*; do
    [[ -d "$candidate" && ! -L "$candidate" ]] || continue
    base="${candidate##*/}"
    [[ ${#base} -gt 16 ]] || continue
    timestamp="${base:0:15}"
    [[ "${base:15:1}" == '-' ]] || continue
    [[ "$timestamp" =~ ^[0-9]{8}-[0-9]{6}$ ]] || continue
    remainder="${base:16}"
    [[ "$remainder" =~ ^[A-Za-z0-9._-]+-([0-9a-f]{40}|[0-9a-f]{64})$ ]] ||
      continue
    last_used="$timestamp"
    if [[ -f "$candidate/.git/ref-repo-last-used" ]]; then
      IFS= read -r last_used < "$candidate/.git/ref-repo-last-used" ||
        last_used="$timestamp"
      [[ "$last_used" =~ ^[0-9]{8}-[0-9]{6}$ ]] || last_used="$timestamp"
    fi
    if [[ "$last_used" < "$cutoff" ]]; then
      rm -rf -- "$candidate"
    fi
  done
}

cache_name_hash() {
  local path base timestamp remainder prefix hash
  path="$1"
  base="${path##*/}"
  [[ ${#base} -gt 16 ]] || return 1
  timestamp="${base:0:15}"
  [[ "${base:15:1}" == '-' ]] || return 1
  [[ "$timestamp" =~ ^[0-9]{8}-[0-9]{6}$ ]] || return 1
  remainder="${base:16}"
  prefix="${REPO_NAME}-"
  [[ "$remainder" == "$prefix"* ]] || return 1
  hash="${remainder:${#prefix}}"
  is_full_hash "$hash" || return 1
  normalize_hash "$hash"
  printf '\n'
}

cache_has_hash() {
  local cache expected actual
  cache="$1"
  expected="$(normalize_hash "$2")"
  [[ -d "$cache/.git" && ! -L "$cache" ]] || return 1
  actual="$(git -C "$cache" rev-parse --verify 'HEAD^{commit}' 2>/dev/null)" ||
    return 1
  actual="$(normalize_hash "$actual")"
  [[ "$actual" == "$expected" ]]
}

metadata_has_record() {
  local cache expected_immutable expected_url expected_ref expected_commit
  local stored_immutable stored_url stored_ref stored_commit
  cache="$1"
  expected_immutable="$2"
  expected_url="$3"
  expected_ref="$4"
  expected_commit="$(normalize_hash "$5")"
  [[ -f "$cache/.git/ref-repo-meta" ]] || return 1

  while IFS=$'\t' read -r stored_immutable stored_url stored_ref stored_commit; do
    stored_commit="$(normalize_hash "$stored_commit")"
    if [[ "$stored_immutable" == "$expected_immutable" &&
          "$stored_url" == "$expected_url" &&
          "$stored_ref" == "$expected_ref" &&
          "$stored_commit" == "$expected_commit" ]]; then
      return 0
    fi
  done < "$cache/.git/ref-repo-meta"
  return 1
}

record_metadata() {
  local cache immutable url ref commit
  cache="$1"
  immutable="$2"
  url="$3"
  ref="$4"
  commit="$(normalize_hash "$5")"
  if ! metadata_has_record "$cache" "$immutable" "$url" "$ref" "$commit"; then
    printf '%s\t%s\t%s\t%s\n' "$immutable" "$url" "$ref" "$commit" \
      >> "$cache/.git/ref-repo-meta"
  fi
}

merge_metadata() {
  local source target immutable url ref commit
  source="$1"
  target="$2"
  [[ "$source" != "$target" ]] || return 0
  [[ -f "$source/.git/ref-repo-meta" ]] || return 0

  while IFS=$'\t' read -r immutable url ref commit; do
    [[ -n "$immutable" && -n "$url" && -n "$ref" && -n "$commit" ]] ||
      continue
    record_metadata "$target" "$immutable" "$url" "$ref" "$commit"
  done < "$source/.git/ref-repo-meta"
}

find_hash_cache() {
  local expected candidate candidate_hash latest
  expected="$(normalize_hash "$1")"
  latest=''
  for candidate in "$CACHE_ROOT"/*-"$REPO_NAME"-"$expected"; do
    [[ -d "$candidate" && ! -L "$candidate" ]] || continue
    candidate_hash="$(cache_name_hash "$candidate" 2>/dev/null)" || continue
    [[ "$candidate_hash" == "$expected" ]] || continue
    cache_has_hash "$candidate" "$expected" || continue
    latest="$candidate"
  done
  printf '%s' "$latest"
}

find_immutable_ref_cache() {
  local candidate candidate_hash latest
  latest=''
  for candidate in "$CACHE_ROOT"/*-"$REPO_NAME"-*; do
    [[ -d "$candidate" && ! -L "$candidate" ]] || continue
    candidate_hash="$(cache_name_hash "$candidate" 2>/dev/null)" || continue
    cache_has_hash "$candidate" "$candidate_hash" || continue
    metadata_has_record "$candidate" true "$REPO_URL" "$REQUESTED_REF" \
      "$candidate_hash" || continue
    latest="$candidate"
  done
  printf '%s' "$latest"
}

refresh_cache_timestamp() {
  local cache hash timestamp
  cache="$1"
  hash="$(normalize_hash "$2")"
  timestamp="$(current_timestamp)"
  cache_has_hash "$cache" "$hash" ||
    die "cannot refresh an invalid cache: $cache"
  printf '%s\n' "$timestamp" > "$cache/.git/ref-repo-last-used"

  cleanup_expired
  printf '%s' "$cache"
}

resolve_abbreviated_hash() {
  local prefix matches count
  prefix="$(normalize_hash "$1")"
  matches="$(git ls-remote "$REPO_URL" |
    awk -v prefix="$prefix" 'index(tolower($1), prefix) == 1 { print tolower($1) }' |
    sort -u)"
  count="$(printf '%s\n' "$matches" | awk 'NF { count++ } END { print count + 0 }')"
  [[ "$count" -eq 1 ]] ||
    die "abbreviated hash '$1' does not uniquely identify an advertised remote object"
  printf '%s' "$matches"
}

TEMP_DIR=''
CACHE_LOCK_DIR=''
CACHE_LOCK_HELD=false

cleanup_temporary() {
  if [[ -n "$TEMP_DIR" && -d "$TEMP_DIR" ]]; then
    rm -rf -- "$TEMP_DIR"
  fi
}

release_cache_lock() {
  local owner_pid
  [[ "$CACHE_LOCK_HELD" == true ]] || return 0
  owner_pid=''
  if [[ -f "$CACHE_LOCK_DIR/pid" ]]; then
    IFS= read -r owner_pid < "$CACHE_LOCK_DIR/pid" || true
  fi
  if [[ "$owner_pid" == "$$" ]]; then
    rm -rf -- "$CACHE_LOCK_DIR"
  fi
  CACHE_LOCK_HELD=false
}

acquire_cache_lock() {
  local attempts owner_pid stale_lock
  attempts=0
  while ! mkdir "$CACHE_LOCK_DIR" 2>/dev/null; do
    owner_pid=''
    if [[ -f "$CACHE_LOCK_DIR/pid" ]]; then
      IFS= read -r owner_pid < "$CACHE_LOCK_DIR/pid" || true
    fi
    if [[ "$owner_pid" =~ ^[0-9]+$ ]] &&
      ! kill -0 "$owner_pid" 2>/dev/null; then
      stale_lock="$CACHE_LOCK_DIR.stale.$$.$attempts"
      if mv -- "$CACHE_LOCK_DIR" "$stale_lock" 2>/dev/null; then
        rm -rf -- "$stale_lock"
        continue
      fi
    fi
    attempts=$((attempts + 1))
    [[ "$attempts" -lt 600 ]] ||
      die 'timed out waiting for the reference cache lock'
    sleep 0.05
  done
  CACHE_LOCK_HELD=true
  printf '%s\n' "$$" > "$CACHE_LOCK_DIR/pid"
}

cleanup_all() {
  cleanup_temporary
  release_cache_lock
}
trap cleanup_all EXIT HUP INT TERM

materialize_ref() {
  local fetch_ref
  TEMP_DIR="$(mktemp -d "$CACHE_ROOT/.clone.XXXXXX")" ||
    die 'cannot create a temporary cache directory'

  if ! git clone --quiet --depth=1 --no-checkout -- "$REPO_URL" "$TEMP_DIR"; then
    die "failed to clone '$REPO_URL'"
  fi

  if is_full_hash "$REQUESTED_REF"; then
    fetch_ref="$(normalize_hash "$REQUESTED_REF")"
    if ! git -C "$TEMP_DIR" cat-file -e "$fetch_ref^{commit}" 2>/dev/null; then
      git -C "$TEMP_DIR" fetch --quiet --depth=1 origin "$fetch_ref" ||
        die "cannot fetch commit '$REQUESTED_REF'"
    fi
    RESOLVED_HASH="$(git -C "$TEMP_DIR" rev-parse --verify "$fetch_ref^{commit}")" ||
      die "cannot resolve commit '$REQUESTED_REF'"
  else
    fetch_ref="$REQUESTED_REF"
    if is_abbreviated_hash "$REQUESTED_REF"; then
      fetch_ref="$(resolve_abbreviated_hash "$REQUESTED_REF")"
    fi
    git -C "$TEMP_DIR" fetch --quiet --depth=1 origin "$fetch_ref" ||
      die "cannot fetch ref '$REQUESTED_REF'"
    RESOLVED_HASH="$(git -C "$TEMP_DIR" rev-parse --verify 'FETCH_HEAD^{commit}')" ||
      die "cannot resolve ref '$REQUESTED_REF' to a commit"
  fi

  RESOLVED_HASH="$(normalize_hash "$RESOLVED_HASH")"
  git -C "$TEMP_DIR" checkout --quiet --detach "$RESOLVED_HASH" ||
    die "cannot check out commit '$RESOLVED_HASH'"
  record_metadata "$TEMP_DIR" "$EFFECTIVE_IMMUTABLE" "$REPO_URL" \
    "$REQUESTED_REF" "$RESOLVED_HASH"
}

IMMUTABLE=false
if [[ "${1:-}" == '--immutable' ]]; then
  IMMUTABLE=true
  shift
fi
if [[ "$#" -ne 2 ]]; then
  usage
  exit 2
fi

REPO_URL="$1"
REQUESTED_REF="$2"
[[ -n "$REPO_URL" && -n "$REQUESTED_REF" ]] || die 'URL and ref must not be empty'
[[ "$REQUESTED_REF" != -* ]] || die 'ref must not begin with a hyphen'
case "$REPO_URL$REQUESTED_REF" in
  *$'\n'*|*$'\t'*) die 'URL and ref must not contain tabs or newlines' ;;
esac

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
CACHE_ROOT="$SCRIPT_DIR/ref-repos"
mkdir -p "$CACHE_ROOT"
CACHE_LOCK_DIR="$CACHE_ROOT/.ref-repo.lock"
REPO_NAME="$(repository_name "$REPO_URL")"

EFFECTIVE_IMMUTABLE="$IMMUTABLE"
if is_full_hash "$REQUESTED_REF"; then
  EFFECTIVE_IMMUTABLE=true
fi

CACHE=''
acquire_cache_lock
cleanup_expired
if [[ "$EFFECTIVE_IMMUTABLE" == true ]]; then
  if is_full_hash "$REQUESTED_REF"; then
    CACHE="$(find_hash_cache "$REQUESTED_REF")"
  else
    CACHE="$(find_immutable_ref_cache)"
  fi
  if [[ -n "$CACHE" ]]; then
    RESOLVED_HASH="$(cache_name_hash "$CACHE")"
    CACHE="$(refresh_cache_timestamp "$CACHE" "$RESOLVED_HASH")"
    record_metadata "$CACHE" true "$REPO_URL" "$REQUESTED_REF" "$RESOLVED_HASH"
    printf '%s\n' "$CACHE"
    release_cache_lock
    exit 0
  fi
fi
release_cache_lock

materialize_ref

acquire_cache_lock
EXISTING_CACHE="$(find_hash_cache "$RESOLVED_HASH")"
if [[ -n "$EXISTING_CACHE" ]]; then
  merge_metadata "$TEMP_DIR" "$EXISTING_CACHE"
  rm -rf -- "$TEMP_DIR"
  TEMP_DIR=''
  CACHE="$EXISTING_CACHE"
else
  DESTINATION="$CACHE_ROOT/$(current_timestamp)-$REPO_NAME-$RESOLVED_HASH"
  if [[ -e "$DESTINATION" ]]; then
    cache_has_hash "$DESTINATION" "$RESOLVED_HASH" ||
      die "cache destination exists but is invalid: $DESTINATION"
    merge_metadata "$TEMP_DIR" "$DESTINATION"
    rm -rf -- "$TEMP_DIR"
  else
    mv -- "$TEMP_DIR" "$DESTINATION"
  fi
  TEMP_DIR=''
  CACHE="$DESTINATION"
fi

CACHE="$(refresh_cache_timestamp "$CACHE" "$RESOLVED_HASH")"
record_metadata "$CACHE" "$EFFECTIVE_IMMUTABLE" "$REPO_URL" \
  "$REQUESTED_REF" "$RESOLVED_HASH"
printf '%s\n' "$CACHE"
release_cache_lock
