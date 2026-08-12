# macOS 版本

原生 Swift/AppKit 实现，最低支持 macOS 13。

## 构建

需要 Xcode Command Line Tools：

```zsh
xcode-select --install
chmod +x build-universal.sh
./build-universal.sh
```

脚本分别构建 `arm64` 和 `x86_64`，合并为 Universal 2 应用，并进行 ad-hoc 签名。输出为 `build/猫咪桌宠.app`。

如果要面向公众免警告分发，需要 Apple Developer ID、notarization 和 stapling；这些凭据不包含在仓库中。
