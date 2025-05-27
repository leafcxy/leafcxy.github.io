---
title: 树莓派wifi配置
date: 2023-07-13 17:30:06
tags:
---

wpa_supplicant.conf

<!-- more -->

ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=CN

network={
	ssid="cxy"
	psk="cxy12345@2"
	key_mgmt=WPA-PSK
}

