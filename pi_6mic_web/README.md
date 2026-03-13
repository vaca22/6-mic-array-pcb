# 6 路麦克风实时波形 Web

在树莓派上运行，电脑浏览器访问可查看 8 通道实时波形（6 路麦克风 + 2 路回声参考）。

## 通道顺序（seeed-8mic-voicecard 实测）

设备为 8 通道：**Ch0/Ch1 = 麦1/麦2，Ch2/Ch3 = 回声参考（用于 AEC，通常几乎不动），Ch4～Ch7 = 麦3～麦6**。与 Seeed Wiki 写的「前 6 路麦、后 2 路 echo」顺序不一致，以实测为准。

## 文件

- `server.py` — 后端：arecord 采集 8ch，SSE 推送；提供页面与 `/stream`
- `index.html` — 前端：8 条实时波形（标签区分麦与回声参考）
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
