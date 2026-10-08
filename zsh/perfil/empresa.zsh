# Perfil empresa: carregado pelo zshrc antes do ~/.zshrc.local.
# Ferramentas da empresa entram aqui; tokens e URLs internas vão no ~/.zshrc.local.

# Oracle Cloud CLI (instalada em ~/lib/oracle-cli, com o wrapper em ~/bin/oci)
_oci="$HOME/lib/oracle-cli/lib/python3.10/site-packages/oci_cli/bin/oci_autocomplete.sh"
[[ -e "$_oci" ]] && source "$_oci"
unset _oci
