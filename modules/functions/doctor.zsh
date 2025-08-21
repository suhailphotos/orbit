prompt_doctor() {
  echo "=== versions ==="; starship --version; zsh --version
  echo "=== term ==="; echo TERM=$TERM; infocmp $TERM | head -n1
  echo "=== size ==="; stty size; echo COLUMNS=$COLUMNS LINES=$LINES
  echo "=== locale ==="; locale | egrep '^(LC_ALL|LANG|LC_CTYPE)='
  echo "=== zsh vars ==="; print -r -- "ZLE_RPROMPT_INDENT=${ZLE_RPROMPT_INDENT-<unset>}"
  echo "=== RPROMPT bytes ==="; print -rn -- $RPROMPT | hexdump -C | tail -n1
}
