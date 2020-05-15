
# KLife

#### Kaleido Life


[1]: https://tinram.github.io/images/klife.jpg
![KLife][1]


## Controls

action | key |
:--- | :--- |
paint black | <kbd>mouse left</kbd> |
paint white | <kbd>mouse right</kbd> |
parameters | <kbd>F1</kbd> - <kbd>F4</kbd> |
reset / clear | <kbd>R</kbd> |
screenshot |<kbd>S</kbd> |
exit | <kbd>ESC</kbd> |


## Build

Install [FreeBASIC](http://www.freebasic.net/forum/viewforum.php?f=1) compiler (*fbc*).

(KLife can be compiled with either the x32 or x64 version of *fbc*, but x32-compilation will require the screen pointer datatype to be changed (see source comment).)

Ensure GCC is available: `whereis gcc`

### Linux

```bash
    make
```

### Windows / Compile Manually

```bash
    fbc KLife.bas -w all -gen gcc -O max -Wl -s
```

or aim for max speed on slower PCs (-march and -mtune make a noticeable difference):

```bash
    fbc KLife.bas -w all -gen gcc -Wl -s -Wc -Ofast,-march=native,-mtune=native,-funroll-loops,-fomit-frame-pointer,-fivopts
```


## Credits

+ John Horton Conway (Game of Life)
+ Matt Pearson (inspiration)
+ David Watson (Pythagoras code)


## License

Licensed under the [MIT License](https://github.com/Tinram/KLife/blob/master/LICENSE).