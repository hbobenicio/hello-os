# minimal-bootloader

A dummy minimal MBR bootloader

## Build and Run

```bash
make
make run
```

## Command Snippets

Run......: qemu-system-i386 -fda os.bin
Run2.....: qemu-system-i386 -drive file=os.bin,format=raw,index=0,media=disk (no warnings/cleanest)
Run3.....: qemu-system-i386 os.bin

## References

- [Making an OS (x86) by Daedalus Community](https://youtube.com/playlist?list=PLm3B56ql_akNcvH8vvJRYOc7TbYhRs19M&si=BhSDtwbW3JNQH7Mo)
- [nanobyte "Building a bootloader" and "Building an OS" playlists](https://www.youtube.com/@nanobyte-dev/playlists)
- [Web Archive of VGA Programming](https://web.archive.org/web/20240804003415/http://www.brackeen.com/vga/index.html)
- [Wikipedia: Video Mode 13h](https://en.wikipedia.org/wiki/Mode_13h)
