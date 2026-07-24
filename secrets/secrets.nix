# Rules file for ragenix/agenix. Lists, per encrypted *.age file, which public
# keys may decrypt it. Committed to git; contains PUBLIC keys only.
#
# Re-encrypt all secrets after changing recipients:
#   cd /etc/nixos/secrets && ragenix --rekey -i /etc/ssh/ssh_host_ed25519_key
let
  # Host key (decrypts at boot). From /etc/ssh/ssh_host_ed25519_key.pub
  host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICqwJlbUfnNvj6GVi5vf1haYez3SVupslHESXsT+7heh";

  # Personal key for creating/editing secrets (private half stays in ~/.ssh).
  admin = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIProUN0omJGULZe2Sro6yS846cpOxlrhRhtVxTl3OlHr";

  users = [ admin ];
  hosts = [ host ];
in
{
  # One entry per secret. Add lines here BEFORE running `ragenix -e <name>.age`.
  # Example:
  #   "rustdesk-key.age".publicKeys = users ++ hosts;
}
