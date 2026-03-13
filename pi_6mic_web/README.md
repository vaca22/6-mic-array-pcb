# 6 路麦克风实时波形 Web

在树莓派上运行，电脑浏览器访问可查看 6 路麦克风实时波形。

## 文件

- `server.py` — 后端：arecord 采集 6ch，SSE 推送；提供页面与 `/stream`
- `index.html` — 前端：6 条实时波形
- `6mic-web.service` — systemd 单元（部署到 Pi 时用）

## 部署到树莓派

```bash
# 从本机同步到 Pi（替换为 Pi 的 IP）
rsync -az /path/to/6-mic-array-pcb/pi_6mic_web/ pi@<pi-ip>:~/6mic_web/

# 在 Pi 上安装并启动服务
ssh pi@<pi-ip>
sudo cp ~/6mic_web/6mic-web.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable 6mic-web.service
sudo systemctl start 6mic-web.service
```

## 访问

浏览器打开：`http://<树莓派IP>:8080`
