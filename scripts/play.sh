#!/bin/bash
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
paplay "$REPO_DIR/sounds/$1" &
