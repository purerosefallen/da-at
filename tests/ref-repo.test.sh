#!/usr/bin/env bash

set -euo pipefail
export LC_ALL=C

REPOSITORY_ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/ref-repo-test.XXXXXX")"

cleanup() {
  rm -rf -- "$TEST_ROOT"
}
trap cleanup EXIT HUP INT TERM

REMOTE_REPOSITORY="$TEST_ROOT/remote.git"
SOURCE_REPOSITORY="$TEST_ROOT/source"
TEST_HELPER_ROOT="$TEST_ROOT/helper"
SLOW_BIN="$TEST_ROOT/bin"

git init --quiet --bare "$REMOTE_REPOSITORY"
git init --quiet "$SOURCE_REPOSITORY"
git -C "$SOURCE_REPOSITORY" config user.name 'Ref Repo Test'
git -C "$SOURCE_REPOSITORY" config user.email 'ref-repo-test@example.invalid'
printf '%s\n' 'fixture' > "$SOURCE_REPOSITORY/README.md"
git -C "$SOURCE_REPOSITORY" add README.md
git -C "$SOURCE_REPOSITORY" commit --quiet -m 'fixture'
git -C "$SOURCE_REPOSITORY" branch -M master
git -C "$SOURCE_REPOSITORY" remote add origin "$REMOTE_REPOSITORY"
git -C "$SOURCE_REPOSITORY" push --quiet -u origin master
git -C "$REMOTE_REPOSITORY" symbolic-ref HEAD refs/heads/master
EXPECTED_COMMIT="$(git -C "$SOURCE_REPOSITORY" rev-parse HEAD)"

mkdir -p "$TEST_HELPER_ROOT" "$SLOW_BIN"
cp "$REPOSITORY_ROOT/ref-repo.sh" "$TEST_HELPER_ROOT/ref-repo.sh"
chmod +x "$TEST_HELPER_ROOT/ref-repo.sh"

printf '%s\n' \
  '#!/usr/bin/env bash' \
  'sleep 0.2' \
  'exec /bin/mv "$@"' > "$SLOW_BIN/mv"
chmod +x "$SLOW_BIN/mv"

pids=()
for index in 1 2 3 4 5 6 7 8; do
  PATH="$SLOW_BIN:/usr/bin:/bin" \
    "$TEST_HELPER_ROOT/ref-repo.sh" \
    "file://$REMOTE_REPOSITORY" master \
    > "$TEST_ROOT/output-$index" &
  pids+=("$!")
done

for pid in "${pids[@]}"; do
  wait "$pid"
done

for index in 1 2 3 4 5 6 7 8; do
  cache="$(sed -n '1p' "$TEST_ROOT/output-$index")"
  [[ -n "$cache" ]] || {
    printf 'invocation %s did not print a cache path\n' "$index" >&2
    exit 1
  }
  cache_parent="$(CDPATH= cd -- "$(dirname -- "$cache")" && pwd -P)"
  expected_parent="$(CDPATH= cd -- "$TEST_HELPER_ROOT/ref-repos" && pwd -P)"
  [[ "$cache_parent" == "$expected_parent" ]] || {
    printf 'invocation %s returned a nested cache path: %s\n' \
      "$index" "$cache" >&2
    exit 1
  }
  [[ "$(git -C "$cache" rev-parse HEAD)" == "$EXPECTED_COMMIT" ]] || {
    printf 'invocation %s returned the wrong commit\n' "$index" >&2
    exit 1
  }
done

if find "$TEST_HELPER_ROOT/ref-repos" -mindepth 3 -type d -name .git \
  -print -quit | grep -q .; then
  printf 'a checkout was nested inside another cache directory\n' >&2
  exit 1
fi

[[ ! -e "$TEST_HELPER_ROOT/ref-repos/.ref-repo.lock" ]] || {
  printf 'the cache lock was not removed\n' >&2
  exit 1
}

printf 'ref-repo concurrency test passed\n'
