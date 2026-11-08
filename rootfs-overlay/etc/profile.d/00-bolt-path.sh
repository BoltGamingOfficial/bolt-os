# Ensure standard executable paths are available in login shells.
for bolt_dir in /usr/local/sbin /usr/local/bin /usr/bin; do
  case ":\${PATH:-}:" in
    *":$bolt_dir:"*) ;;
    *) PATH="$bolt_dir\${PATH:+:$PATH}" ;;
  esac
done
export PATH
