# Midnight Commander

If shift-arrow combinations do not work in Midnight Commander, first check the escape sequence in console window using
```
showkey -a
```
You should get something like this:
```
^[1\;2D
```
Then in a file ```/usr/share/mc/mc.lib``` in a section ```[terminal:console]``` you can add
```
shift-right=\\e[1\;2C
shift-left=\\e[1\;2D
shift-up=\\e[1\;2A
shift-down=\\e[1\;2B
ctrl-right=\\e[1\;5C
ctrl-left=\\e[1\;5D

```
