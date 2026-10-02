# lazysql in a split next to a shell (ctrl+b s in the demo config, alt+s in the README), customers table.
Output ".vhs/split.gif"
Source "docs/tapes/config.tape"

Hide
Type '"$HERDR_DEMO" herdr' Enter
Sleep 4s
Type "clear; ls" Enter
Sleep 1s
Ctrl+B
Type "s"
Sleep 3s
# connect to "shop (local)", expand public and its tables, open the first table
Enter
Sleep 3s
Type "jjj"
Sleep 500ms
Enter
Sleep 1.5s
Type "j"
Sleep 500ms
Enter
Sleep 1.5s
Type "j"
Sleep 500ms
Enter
Sleep 3s
Show
Sleep 300ms
Screenshot "docs/screenshots/split.png"
