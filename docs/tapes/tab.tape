# lazysql in its own tab (ctrl+b t in the demo config, alt+shift+s in the README), orders table.
Output ".vhs/tab.gif"
Source "docs/tapes/config.tape"

Hide
Type '"$HERDR_DEMO" herdr' Enter
Sleep 4s
Type "clear; ls" Enter
Sleep 1s
# the first press opens the tab, the second one switches to it
Ctrl+B
Type "t"
Sleep 3s
Ctrl+B
Type "t"
Sleep 2s
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
Type "jjj"
Sleep 500ms
Enter
Sleep 3s
Show
Sleep 300ms
Screenshot "docs/screenshots/tab.png"
