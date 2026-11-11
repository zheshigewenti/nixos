# desktop 的 SSH 授权公钥，装完即可远程登录，不用再碰实体机。
#
# 用法：把 xps 上 `cat ~/.ssh/id_ed25519.pub` 的输出替换下面的占位内容。
# 每行一个公钥，导出为一个 Nix 列表。
[
  # "ssh-ed25519 AAAA... vincent@xps"
]
