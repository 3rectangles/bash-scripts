for file in /home/sc-460-user/vscode_proj/miscellaneous/bt_pars*.csv; do
  for uid in $(cat "${file}" | tr -d '\r'); do
    echo "${uid}"
  done
done
