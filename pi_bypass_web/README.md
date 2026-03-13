# 旁路由配置 Web

在树莓派上运行，浏览器可配置是否使用旁路由，并测试能否访问谷歌。

- 端口：**8081**
- 访问：`http://<树莓派IP>:8081`

## 部署到树莓派

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
- `bypass-ctl.sh` — 旁路由开关（需 sudo）
- `bypass-web.service` — systemd 单元
