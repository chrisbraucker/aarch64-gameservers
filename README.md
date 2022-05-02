# AArch64 GameServers

This is a haphazardly growing (depending on my gaming habits) collection of game server images for the AArch64 platform.
These are mainly aimed to run on Oracle Ampere Altra instances, but also likely support AWS' Graviton instances out of the box since the chips are very similar.

The Dockerfiles provided here make heavy use of the amazing work of https://github.com/ptitSeb by providing emulation through

- https://ptitseb.github.io/box86/
- https://ptitseb.github.io/box64/

Because these repositories are very actively developed, all images use bleeding edge commits over releases.
Be warned that this may break things.

Happy gaming!
