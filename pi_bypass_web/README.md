# 旁路由配置 Web

在树莓派上运行，浏览器可配置是否使用旁路由，并测试能否访问谷歌。

- 端口：**8081**
- 访问：`http://<树莓派IP>:8081`

## 使用旁路由 + 从 GitHub 部署（推荐）

先让树莓派能访问外网（使用旁路由或软路由代理），再从 GitHub 拉取本仓库并部署到 Pi：

1. **在树莓派上启用旁路由**（若已配置过 `/usr/local/bin/bypass-proxy.sh`）：
   ```bash
   sudo /usr/local/bin/bypass-ctl.sh enable   # 若已安装 bypass-ctl.sh
   # 或按你现有方式启用代理，使 Pi 能访问 google.com / github.com
   ```
2. **在树莓派上一键部署**（克隆 GitHub 并安装本 Web）：
   ```bash
   curl -sSL https://raw.githubusercontent.com/vaca22/6-mic-array-pcb/main/pi_bypass_web/deploy-from-github.sh | bash
   ```
   或先克隆再执行：
   ```bash
   git clone --depth 1 https://github.com/vaca22/6-mic-array-pcb.git ~/6-mic-array-pcb
   bash ~/6-mic-array-pcb/pi_bypass_web/deploy-from-github.sh
   ```
3. 部署完成后访问：`http://<树莓派IP>:8081`。

若无法直连 GitHub，可从本机用 rsync 部署（见下方「部署到树莓派」）。

---

## 部署到树莓派（本机 rsync）

### 1. 复制控制脚本并配置 sudo

```bash
# 复制项目到 Pi
rsync -az pi_bypass_web/ pi@<pi-ip>:~/bypass_web/

# SSH 到 Pi 后执行：
sudo cp ~/bypass_web/bypass-ctl.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/bypass-ctl.sh

# 允许 pi 无密码执行 bypass-ctl.sh
echo 'pi ALL=(ALL) NOPASSWD: /usr/local/bin/bypass-ctl.sh' | sudo tee /etc/sudoers.d/bypass-ctl
sudo chmod 440 /etc/sudoers.d/bypass-ctl
```

### 2. 旁路由开机逻辑（可选）

若希望「开机自动使用旁路由」，安装并启用：

```bash
sudo cp ~/bypass_web/bypass-gateway.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable bypass-gateway.service
```

之后可在网页里点「不使用旁路由」关闭，并禁用该服务；点「使用旁路由」会重新启用。

### 3. 安装并启用配置网页服务

```bash
sudo cp ~/bypass_web/bypass-web.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable bypass-web.service
sudo systemctl start bypass-web.service
```

## 文件说明

- `server.py` — HTTP 服务与 /api/status、/api/enable、/api/disable、/api/test-google
- `index.html` — 配置页与测试按钮
- `bypass-ctl.sh` — 旁路由开关（调用 bypass-proxy.sh，需 sudo）
- `bypass-proxy.sh` — **透明代理本体**：redsocks + iptables，将本机 TCP 转到同网段 .100:1070 的 SOCKS5。部署时需复制到 `/usr/local/bin/`，并安装依赖：`sudo apt-get install redsocks iptables`
- `bypass-web.service` — 配置网页 systemd 单元
- `bypass-gateway.service` — 开机自动启用旁路由（可选）
- `deploy-from-github.sh` — 在 Pi 上一键从 GitHub 克隆并部署本 Web（需先启用旁路由以访问 GitHub）
