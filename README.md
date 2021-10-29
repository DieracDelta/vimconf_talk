# What is this?

Tutorial/template for using Nix to create a portable Vim "distro" for vimconf that theoretically runs on ANY linux distribution.

[Accompanying writeup](https://justin.restivo.me/posts/2021-10-24-neovim-nix.html).

# Usage

For non-nixos linux distros: Three lines of bash: from zero to fully configured Vim with Nix.

```bash
git clone https://github.com/DieracDelta/vimconf_talk.git # (obtain code)
cd vimconf_talk && bash setup.sh                          # (install nix, modify bashrc)
source $HOME/.bashrc && nix run .                         # (build and run NeoVim)
```

For nixos with flakes enabled:

```bash
nix run github:DieracDelta/vimconf_talk
```

# Removal

```bash
rm -rf $PWD
```

# Thank yous

Special thanks to:
- [Gytis](https://github.com/gytis-ivaskevicius/) for completely rewriting my vim2lua translator the night or two before the talk
- [Zach](https://github.com/zachcoyle). NeoVitality was the inspiration for this.
- [Aaron](https://github.com/aaronchall) for listening and giving feedback.
- [DavHau](https://github.com/DavHau/nix-portable) for his really awesome nix-portable
