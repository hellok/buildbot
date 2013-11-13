==> Caveats
You may also wish to install tuntap:

  The TunTap project provides kernel extensions for Mac OS X that allow
  creation of virtual network interfaces.

  http://tuntaposx.sourceforge.net/

Because these are kernel extensions, there is no Homebrew formula for tuntap.

For OpenVPN to work as a server, you will need to create configuration file
in /usr/local/etc/openvpn, samples can be found in /usr/local/Cellar/openvpn/2.3.2/share/doc/openvpn

To have launchd start openvpn at startup:
    sudo cp -fv /usr/local/opt/openvpn/*.plist /Library/LaunchDaemons
Then to load openvpn now:
    sudo launchctl load /Library/LaunchDaemons/homebrew.mxcl.openvpn.plist
Warning: /usr/local/sbin is not in your PATH
You can amend this by altering your ~/.bashrc file

将其安装为 Tunnelblick VPN 配置:

1. 移动或复制一个 OpenVPN 配置文件 (.ovpn 或 .conf 后缀) 到桌面上新建的 '空白 Tunnelblick VPN 配置' 文件夹.

2.与将此配置文件相关的密钥或证书文件移动或复制到此文件夹.

3. 将文件夹重命名为你想要的名字. 新的名字将是此配置在 Tunnelblick 中的名字.

4. 此文件夹的后缀改为  .tblk.

5. 双击此文件夹, 这将安装此配置.

新的配置将立即能够在 Tunnelblick 中使用.

(为了方便起见, 此文件夹已在一个 Finder 窗口中打开.)