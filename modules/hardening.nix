# Kernel attack-surface reduction.
#
# Blacklists rarely-used modules that have a track record of local-privesc /
# RCE bugs (the "modules involved in recent exploits" you asked for), pins a
# recent kernel so the unblacklistable core (nf_tables, etc.) is patched, and
# applies a modest set of sysctls. This is deliberately lighter than NixOS's
# full `profiles/hardened` (which breaks too much for a daily-driver laptop).
{ lib, pkgs, ... }:
{
  boot.blacklistedKernelModules = [
    # --- Obscure / legacy network protocols (history of UAF & privesc CVEs) ---
    "dccp" # Datagram Congestion Control Protocol
    "sctp" # Stream Control Transmission Protocol
    "rds" # Reliable Datagram Sockets
    "tipc" # Transparent Inter-Process Communication
    "n-hdlc" # High-level Data Link Control line discipline
    "n_gsm" # GSM 0710 tty line discipline (CVE-2024-36016 privesc)
    "ax25"
    "netrom"
    "x25"
    "rose"
    "decnet"
    "econet"
    "af_802154"
    "ipx"
    "appletalk"
    "psnap"
    "p8023"
    "p8022"
    "can"
    "atm"

    # --- Rarely-needed filesystems / drivers with notable CVEs ---
    "cramfs"
    "freevxfs"
    "jffs2"
    "hfs"
    "hfsplus"
    "udf"
    "ksmbd" # in-kernel SMB3 server (CVE-2025-37947 OOB-write -> root)
    "vivid" # V4L2 test driver, repeated privesc history
  ];

  # Track the latest stable kernel so nf_tables / core bugs
  # (e.g. CVE-2024-1086 class) ship patched. nf_tables cannot be blacklisted —
  # it is the firewall backend NixOS and vopono rely on.
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

  boot.kernel.sysctl = {
    # Hide kernel pointers and the kernel log from unprivileged users.
    "kernel.kptr_restrict" = 2;
    "kernel.dmesg_restrict" = 1;
    # Restrict ptrace to direct children (blocks process snooping).
    "kernel.yama.ptrace_scope" = 1;
    # Reverse-path filtering.
    "net.ipv4.conf.all.rp_filter" = 1;
    "net.ipv4.conf.default.rp_filter" = 1;

    # --- OPTIONAL, off by default ---------------------------------------------
    # Disabling unprivileged user namespaces blocks a very common local-privesc
    # primitive (including the CVE-2024-1086 nf_tables exploit path, which uses
    # an unprivileged userns to gain CAP_NET_ADMIN). BUT it breaks the Chromium/
    # Electron sandbox and your landrun `sandbox-run` helper (sandbox.nix in the
    # home-manager repo). Docker here is rootful, so docker itself is unaffected.
    # Uncomment to opt in:
    # "kernel.unprivileged_userns_clone" = 0;
    # "user.max_user_namespaces" = 0;
  };
}
