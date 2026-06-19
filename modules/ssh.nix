# SSH server.
#
# `enable` starts sshd and (via openFirewall) opens the configured port. We use
# a non-default port to cut down automated scan/brute-force noise (it's not real
# security on its own — keep relying on key auth/strong passwords). Defaults here
# are password-auth ON so you can log in with arlp's password immediately, root
# login OFF. For better security, add your public key (below) and flip
# PasswordAuthentication to false to make it key-only.
#
# Connect with:  ssh -p 58022 arlp@<laptop-ip>
{ ... }:
{
  services.openssh = {
    enable = true;
    openFirewall = true;
    # ---- non-default SSH port (change to taste) ----
    ports = [ 58022 ];
    settings = {
      PermitRootLogin = "no";
      # TODO: set to false once you've added an authorized key (key-only auth).
      PasswordAuthentication = true;
      KbdInteractiveAuthentication = false;
    };
  };

  # Key-based login (recommended). Drop your public key(s) here, then set
  # PasswordAuthentication = false above:
  # users.users.arlp.openssh.authorizedKeys.keys = [
  #   "ssh-ed25519 AAAA... you@host"
  # ];
}
