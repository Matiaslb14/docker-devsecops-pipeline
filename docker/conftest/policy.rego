package main

deny[msg] {
  not input.services.api.read_only
  msg := "api.read_only must be true"
}

deny[msg] {
  input.services.api.user == "0:0"
  msg := "api.user cannot be root"
}

deny[msg] {
  not input.services.api.cap_drop
  msg := "api.cap_drop must exist"
}

deny[msg] {
  not has(input.services.api.cap_drop, "ALL")
  msg := "api.cap_drop must include ALL"
}

deny[msg] {
  not has(input.services.api.security_opt, "no-new-privileges:true")
  msg := "api.security_opt must enforce no-new-privileges"
}

deny[msg] {
  not input.services.api.pids_limit
  msg := "api.pids_limit must be set"
}

# helper: true si arr contiene val
has(arr, val) {
  some i
  arr[i] == val
}
