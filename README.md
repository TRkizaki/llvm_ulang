# llvm_ulang

**Prerequisites check**

First, make sure you have LLVM installed. On Pop!_OS:

```
sudo apt install llvm clang
```

Verify:

```
clang --version
llc --version
```

Both should report a version (anything 14+ is fine for this).
`llc` is LLVM's IR-to-assembly compiler; `clang` we'll use as a driver to handle assembly and linking.
