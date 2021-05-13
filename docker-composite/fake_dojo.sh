#!/bin/bash

while [[ $1 == "-c" ]] || [[ $1 == "-print-logs" ]]; do
  shift
  shift
done
(eval "$@")
