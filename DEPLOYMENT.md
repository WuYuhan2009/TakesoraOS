# TakesoraOS 部署指南（从源码到安装）

本文面向第一次接触 Linux 构建流程的用户，目标是最少操作完成 TakesoraOS ISO 生成与安装。

## 1. 构建机要求

- 系统：Debian 12（推荐）或 Ubuntu 22.04+
- CPU：4 核及以上
- 内存：至少 8GB（推荐 16GB）
- 磁盘：至少 60GB 可用空间
- 网络：可访问 Debian 官方源与 Flathub

> 注意：构建过程中会自动执行 `apt-get install` 安装依赖。

## 2. 获取源码

```bash
git clone <你的仓库地址> TakesoraOS
cd TakesoraOS
```

## 3. 一键构建 ISO

### 方式 A：交互式（会提示输入 AI Key）

```bash
chmod +x build.sh
./build.sh
```

### 方式 B：无人值守（推荐 CI/自动化）

```bash
chmod +x build.sh
TAKESORA_AI_API_KEY="你的硅基流动APIKEY" \
TAKESORA_AI_MODEL="deepseek-ai/DeepSeek-V3" \
./build.sh
```

> 提示：只要设置了 `TAKESORA_AI_API_KEY`，构建产物会默认启用 AI 服务。

构建成功后输出：

- `output/takesoraos-amd64.iso`
- `output/sha256.txt`
- `build.log`

## 4. 校验 ISO

```bash
./verify-checksum.sh
```

若显示 `OK` 即通过。

## 5. 启动测试（可选）

### BIOS 测试

```bash
./test-bios.sh
```

### UEFI 测试

```bash
./test-uefi.sh
```

## 6. 写入 U 盘并安装

识别你的 U 盘设备（例如 `/dev/sdb`）：

```bash
lsblk
```

写盘（请把 `/dev/sdX` 替换为你的U盘设备，**不要带分区号**）：

```bash
sudo dd if=output/takesoraos-amd64.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

完成后重启电脑，从 U 盘启动。

## 7. 启动菜单说明

启动后可见：

1. Live mode（体验）
2. Install TakesoraOS（安装）
3. Safe graphics mode（安全图形）
4. Memory test（内存检测）

## 8. 常见问题

### Q1：报错 `security.debian.org bookworm/updates Release does not have a Release file`
这是 Debian 安全源旧写法导致。新脚本会自动修复；你也可以手动修复后再构建：

```bash
sudo sed -Ei 's#^deb[[:space:]]+https?://security\.debian\.org[[:space:]]+bookworm/updates[[:space:]]+#deb http://security.debian.org/debian-security bookworm-security #g' /etc/apt/sources.list /etc/apt/sources.list.d/*.list
sudo apt-get update
./build.sh
```

### Q2：构建失败提示依赖缺失
重新执行：

```bash
sudo apt-get update
sudo apt-get -f install
./build.sh
```

### Q3：`lb config: unrecognized`
不同版本的 live-build 支持参数不一致。当前 `build.sh` 已做自动兼容：会先检测 `lb config --help`，仅传递当前版本支持的参数。

如你仍遇到报错，请先升级 live-build 后重试：

```bash
sudo apt-get update
sudo apt-get install -y live-build
./build.sh
```

### Q4：想彻底重来

```bash
./clean.sh
./build.sh
```

### Q5：AI 默认是否启用？
- 当你提供 `TAKESORA_AI_API_KEY`（或交互输入 API Key）时，脚本会写入 `AI_ENABLED_BY_DEFAULT=1`，默认启用 AI。
- 当 API Key 为空时，脚本会写入 `AI_ENABLED_BY_DEFAULT=0`，默认禁用 AI。

也可以手动修改：`config/includes.chroot/etc/takesora-ai/ai.env`。
