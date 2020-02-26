# history of zsh startup time
## 2020/02/26-2
```console
❯ for i in {1..10} ; do time ( zsh -i -c exit ); done
( zsh -i -c exit; )  0.13s user 0.12s system 95% cpu 0.258 total
( zsh -i -c exit; )  0.13s user 0.11s system 92% cpu 0.257 total
( zsh -i -c exit; )  0.13s user 0.11s system 93% cpu 0.262 total
( zsh -i -c exit; )  0.13s user 0.11s system 91% cpu 0.257 total
( zsh -i -c exit; )  0.13s user 0.11s system 92% cpu 0.253 total
( zsh -i -c exit; )  0.13s user 0.11s system 95% cpu 0.253 total
( zsh -i -c exit; )  0.13s user 0.11s system 94% cpu 0.254 total
( zsh -i -c exit; )  0.13s user 0.11s system 93% cpu 0.251 total
( zsh -i -c exit; )  0.13s user 0.10s system 90% cpu 0.256 total
( zsh -i -c exit; )  0.13s user 0.11s system 94% cpu 0.256 total
```

## 2020/02/26
https://github.com/nekottyo/dotfiles/pull/11


```console
❯ for i in {1..10} ; do time ( zsh -i -c exit ); done
( zsh -i -c exit; )  0.10s user 0.13s system 90% cpu 0.249 total
( zsh -i -c exit; )  0.10s user 0.12s system 91% cpu 0.243 total
( zsh -i -c exit; )  0.10s user 0.13s system 95% cpu 0.241 total
( zsh -i -c exit; )  0.10s user 0.15s system 95% cpu 0.259 total
( zsh -i -c exit; )  0.10s user 0.13s system 93% cpu 0.238 total
( zsh -i -c exit; )  0.10s user 0.13s system 94% cpu 0.241 total
( zsh -i -c exit; )  0.10s user 0.13s system 93% cpu 0.236 total
( zsh -i -c exit; )  0.10s user 0.13s system 94% cpu 0.244 total
( zsh -i -c exit; )  0.09s user 0.13s system 95% cpu 0.234 total
( zsh -i -c exit; )  0.10s user 0.13s system 92% cpu 0.242 total
```

## 2020/02/08
https://github.com/nekottyo/dotfiles/pull/5

starship 捨てた
```console
❯ for i in {1..10} ; do time ( zsh -i -c exit ); done
❯ ( zsh -i -c exit; )  0.10s user 0.12s system 93% cpu 0.230 total
❯ ( zsh -i -c exit; )  0.10s user 0.11s system 93% cpu 0.221 total
❯ ( zsh -i -c exit; )  0.10s user 0.12s system 96% cpu 0.230 total
❯ ( zsh -i -c exit; )  0.10s user 0.11s system 93% cpu 0.228 total
❯ ( zsh -i -c exit; )  0.09s user 0.11s system 94% cpu 0.214 total
❯ ( zsh -i -c exit; )  0.09s user 0.12s system 94% cpu 0.222 total
❯ ( zsh -i -c exit; )  0.10s user 0.12s system 95% cpu 0.228 total
❯ ( zsh -i -c exit; )  0.10s user 0.11s system 94% cpu 0.221 total
❯ ( zsh -i -c exit; )  0.10s user 0.12s system 97% cpu 0.221 total
❯ ( zsh -i -c exit; )  0.10s user 0.11s system 96% cpu 0.219 total
```

starship

```console
❯ for i in {1..10} ; do time ( zsh -i -c exit ); done
( zsh -i -c exit; )  0.09s user 0.21s system 82% cpu 0.361 total
( zsh -i -c exit; )  0.09s user 0.21s system 80% cpu 0.369 total
( zsh -i -c exit; )  0.09s user 0.20s system 82% cpu 0.349 total
( zsh -i -c exit; )  0.09s user 0.22s system 81% cpu 0.378 total
( zsh -i -c exit; )  0.09s user 0.22s system 79% cpu 0.391 total
( zsh -i -c exit; )  0.09s user 0.21s system 80% cpu 0.372 total
( zsh -i -c exit; )  0.09s user 0.19s system 77% cpu 0.352 total
( zsh -i -c exit; )  0.09s user 0.21s system 81% cpu 0.366 total
( zsh -i -c exit; )  0.09s user 0.21s system 81% cpu 0.364 total
( zsh -i -c exit; )  0.09s user 0.21s system 81% cpu 0.372 total
```

## 2019/12/19
```console
❯ for i in {1..10} ; do time ( zsh -i -c exit ); done
( zsh -i -c exit; )  0.07s user 0.16s system 77% cpu 0.290 total
( zsh -i -c exit; )  0.07s user 0.16s system 77% cpu 0.294 total
( zsh -i -c exit; )  0.07s user 0.16s system 71% cpu 0.318 total
( zsh -i -c exit; )  0.07s user 0.17s system 76% cpu 0.313 total
( zsh -i -c exit; )  0.06s user 0.14s system 72% cpu 0.275 total
( zsh -i -c exit; )  0.06s user 0.15s system 73% cpu 0.288 total
( zsh -i -c exit; )  0.06s user 0.15s system 78% cpu 0.272 total
( zsh -i -c exit; )  0.07s user 0.16s system 76% cpu 0.291 total
( zsh -i -c exit; )  0.07s user 0.15s system 74% cpu 0.290 total
( zsh -i -c exit; )  0.07s user 0.16s system 80% cpu 0.279 total
```

## 2019/2/25
https://github.com/nekottyo/dotfiles/pull/1

```console
➜ for i in $(seq 1 10); do time zsh -i -c exit; done

zsh -i -c exit  0.37s user 0.12s system 126% cpu 0.389 total
zsh -i -c exit  0.37s user 0.12s system 121% cpu 0.400 total
zsh -i -c exit  0.34s user 0.13s system 113% cpu 0.415 total
zsh -i -c exit  0.34s user 0.12s system 118% cpu 0.386 total
zsh -i -c exit  0.35s user 0.11s system 127% cpu 0.361 total
zsh -i -c exit  0.33s user 0.12s system 115% cpu 0.388 total
zsh -i -c exit  0.32s user 0.12s system 124% cpu 0.354 total
zsh -i -c exit  0.34s user 0.12s system 124% cpu 0.369 total
zsh -i -c exit  0.33s user 0.13s system 125% cpu 0.363 total
zsh -i -c exit  0.34s user 0.12s system 112% cpu 0.403 total
```

## ~2019/2/25
```console
➜ for i in $(seq 1 10); do time zsh -i -c exit; done

zsh -i -c exit  0.71s user 0.31s system 117% cpu 0.865 total
zsh -i -c exit  0.73s user 0.34s system 119% cpu 0.899 total
zsh -i -c exit  0.69s user 0.34s system 120% cpu 0.856 total
zsh -i -c exit  0.72s user 0.32s system 118% cpu 0.878 total
zsh -i -c exit  0.75s user 0.35s system 118% cpu 0.926 total
zsh -i -c exit  0.71s user 0.36s system 120% cpu 0.890 total
zsh -i -c exit  0.73s user 0.35s system 118% cpu 0.910 total
zsh -i -c exit  0.81s user 0.36s system 118% cpu 0.981 total
zsh -i -c exit  0.77s user 0.34s system 118% cpu 0.935 total
zsh -i -c exit  0.74s user 0.37s system 118% cpu 0.939 total
```
