# TakesoraOS

TakesoraOS 是基于 Debian 12 (Bookworm) 的面向个人用户的桌面 Linux 发行版构建工程。

## 一键构建

```bash
chmod +x build.sh
./build.sh
```

构建完成后产物位于 `output/`：

- `takesoraos-amd64.iso`
- `sha256.txt`
- `build.log`

## 功能覆盖

- Live 模式与图形安装入口（Calamares 配置）
- GNOME 桌面 + GDM + 自动登录（Live）
- Wine / Lutris / Waydroid 兼容层脚本
- AI 服务（硅基流动 API）与权限隔离
- AppArmor / nftables / fail2ban 安全强化
- zram/zswap/BBR/swappiness 等性能优化
- 中国生态（Flatpak Flathub 预装策略）

## 目录结构

- `build.sh`：一键安装依赖 + 生成 ISO
- `clean.sh`：清理构建缓存
- `test-bios.sh`：QEMU BIOS 启动测试
- `test-uefi.sh`：QEMU UEFI 启动测试
- `verify-checksum.sh`：校验 ISO hash
- `config/package-lists/`：系统包清单
- `config/hooks/live/`：chroot 构建钩子
- `config/includes.chroot/`：注入 chroot 的配置与脚本
- `config/includes.binary/`：ISO 启动菜单覆盖
- `config/calamares/`：安装器配置模板


## 部署（快速）

1. 赋予脚本权限并开始构建：

```bash
chmod +x build.sh
./build.sh
```

2. 构建完成后产物在 `output/`：

- `takesoraos-amd64.iso`
- `sha256.txt`
- `build.log`

3. 校验 ISO：

```bash
./verify-checksum.sh
```

4. 本地虚拟机测试：

```bash
./test-bios.sh
./test-uefi.sh
```

详细步骤见 `DEPLOYMENT.md`。
