
# Cross compilation

```
nix repl '<nixpkgs>'
nix repl ~/nixpkgs
nix-repl> pkgsCross
{ aarch64-android-prebuilt = { ... }; aarch64-embedded = { ... }; aarch64-multiplatform = { ... }; aarch64-multiplatform-musl = { ... }; aarch64be-embedded = { ... }; alpha-embedded = { ... }; arm-embedded = { ... }; armhf-embedded = { ... }; armv5te-android-prebuilt = { ... }; armv7a-android-prebuilt = { ... }; armv7l-hf-multiplatform = { ... }; avr = { ... }; ben-nanonote = { ... }; fuloongminipc = { ... }; i686-embedded = { ... }; iphone32 = { ... }; iphone32-simulator = { ... }; iphone64 = { ... }; iphone64-simulator = { ... }; mingw32 = { ... }; mingwW64 = { ... }; musl-power = { ... }; musl32 = { ... }; musl64 = { ... }; muslpi = { ... }; pogoplug4 = { ... }; powernv = { ... }; ppc-embedded = { ... }; ppcle-embedded = { ... }; raspberryPi = { ... }; riscv32 = { ... }; riscv64 = { ... }; scaleway-c1 = { ... }; sheevaplug = { ... }; x86_64-embedded = { ... }; }



nix build -f '<nixpkgs>' pkgsCross.aarch64-multiplatform.hello
```

## Use prepared cross-compilation environments

```
nix-shell /etc/nixos/environments/avr.nix
```

## Resources

https://matthewbauer.us/blog/beginners-guide-to-cross.html
