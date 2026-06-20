# Rhino.fi binary cache — system side.
#
# Nearly everything lives at the USER level: ~/.config/nix/rhino.conf (generated
# by rhino's `setup-nix-conf-and-secrets`) holds the substituters, trusted keys,
# experimental-features, sandbox paths and netrc-file, and home-manager pulls it
# in via `!include ./rhino.conf`. Because `arlp` is a trusted-user (see
# configuration.nix → nix.settings.trusted-users) the daemon honours all of it.
#
# The ONE thing that can't live there: the GCS/S3 credentials. In multi-user nix
# the root nix-daemon performs substitution and does NOT inherit the calling
# user's environment, so it must be told where the creds file is. The setup
# script writes it as arlp:root 0600 — root reads it regardless of owner.
{ ... }:
{
  systemd.services.nix-daemon.environment.AWS_SHARED_CREDENTIALS_FILE =
    "/home/arlp/.config/nix/rhino-aws-credentials";
}
