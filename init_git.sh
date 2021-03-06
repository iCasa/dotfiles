#!/bin/bash

# @author Dumitru Uzun (DUzun.Me)
# @version 1.1.0

if ! command -v git > /dev/null ; then
    echo "Looks like git is not installed"
    exit 1
fi
p=$(dirname "$0")
if ! command -v realpath > /dev/null; then
    . "$p/src/realpath/.realpath"
fi

# [ -n "$BASH" ] && ! command -v __git_ps1 > /dev/null && [ ! -e ~/.git-prompt.sh ] && \
# curl -L -o ~/.git-prompt.sh https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh

gfg="git config --global"

_force=$(echo "$@" | grep -- '-f')
p="$(realpath "$p")/~"
grep -v '^;' "$p/.gitconfig" | while read -r ln; do
    ln="${ln##*( )}"
    if [[ "${ln:0:1}" == "[" ]]; then
        ln=$(echo "${ln:1:${#ln}-2}" | tr -s '\ "' '.')
        _section=${ln%%.}
        # echo [$_section]
    else
        _name=${ln%%=*}
        _value=${ln:${#_name}+1}
        _value=${_value/# /}
        _name=${_name/% /}
        # echo $_section.$_name=$_value
        $gfg "$_section.$_name" "$_value"
    fi
done

echo ""
echo "$gfg:"
_section=user
_username=$(whoami)
_value=
for _name in name email username; do
    _pv=$_value
    _value=$($gfg "$_section.$_name");
    _default=$_value;

    # Try to get a default value for missing git config
    if [ -z "$_default" ] ; then
        if [[ "$_name" == "name" ]]; then
            _default=$(getent passwd "$_username" | cut -d: -f5 | cut -d, -f1)
        elif [[ "$_name" == "email" ]]; then
            _default="$_username@$(hostname)"
        elif [[ "$_name" == "username" ]]; then
            _default=$_username
            if [[ "$_default" == "root" ]] || [[ "$_default" == "user" ]]; then
                if [ -n "$_pv" ]; then
                    _default=${_pv%%\@*}
                fi
            fi
        fi
    fi

    _dvb=" ($_default)";
    [ -z "$_default" ] && _dvb=;

    if [ -z "$_value" ] || [ -n "$_force" ] ; then
        read -r -p "    $_section.$_name$_dvb:" v;
        [ -z "$v" ] && [ -n "$_default" ] && v=$_default
        if [ -n "$v" ]; then
            $gfg "$_section.$_name" "$v";
            _value=$v;
        fi
    else
        echo "    $_section.$_name: $_value";
    fi
done

_name=credential.helper
$gfg $_name > /dev/null
if [ -n "$_os" ] && [[ $? != 0 || "$_name" == "store" ]]; then
    case $_os in
        linux)
            # Try to use KWallet if available
            _ask=$(command -v ksshaskpass) > /dev/null && \
            $gfg core.askpass "$_ask"

            # Try to use Gnome-Keyring if available
            command -v gnome-keyring > /dev/null && \
            $gfg $_name gnome-keyring;
        ;;
        osx)
            $gfg $_name osxkeychain;
        ;;
        windows)
            $gfg $_name wincred;
        ;;
    esac
fi
