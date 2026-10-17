# HighWire<sup>TT</sup> — the SAM TT030 fork of HighWire

**HighWire<sup>TT</sup>** (plain text: HighWireTT) is a **SAM-built fork** of [HighWire](https://github.com/neilrackett/atarist-highwire) (GPL-3.0) for one machine:
an Atari TT030 with an ATW800/2 graphics card (xVDI), FreeMiNT 1.19, XaAES. It is maintained by SAM, the operator's
agent system, on branch **`sam-tt030`**. `main` mirrors upstream untouched.

## What differs from upstream

| Change | Why |
| :--- | :--- |
| Name **HighWire<sup>TT</sup>** (window/menu text `HighWireTT`), version `0.4.8-samN`; About box names the fork and this repo; start page welcomes you to HighWire<sup>TT</sup> | Tell the fork from upstream at a glance (`-samN` counts fork releases on top of the upstream version). |
| `inet.c`: a dotted-quad host is used as-is before `gethostbyname()` | Lets `HTTP_PROXY` be a bare LAN address. Harmless with names. |
| `Makefile`: `WERROR ?= -Werror` (overridable) | The SAM cross toolchain is gcc 15, which warns where upstream's compiler did not. The upstream default is unchanged. |
| `packaging/highwire.cfg` | TT default: `HTTP_PROXY = ttproxy.sam.int:3128` (TLS terminated off the TT), cache in `/var/cache/highwire`. |
| `packaging/build-tt030.sh`, `packaging/upstream-sync.sh` | Reproducible 68030 build; evaluate and build upstream changes. |

## Fork requirements

| ID | Requirement | Acceptance check | Status |
| :--- | :--- | :--- | :--- |
| FR-1 | Relabel as **HighWire<sup>TT</sup>**. GEM menu and window text, where no markup is possible, read `HighWireTT`. The default start page (`html/index.htm`) says *"Welcome to HighWire<sup>TT</sup>, your new favorite Atari TT browser (built by SAM)."* Docs use the new name. (Operator, 2026-10-17.) | Start page on the TT shows the line with TT as superscript. The About box and the XaAES application menu read HighWireTT. | done: text in 0.4.8-sam2; amber-on-black page, logo and footer in 0.4.8-sam4 |

The start page is amber on black (`bgcolor #000000`, text `#d98941`, the amber measured from the operator's reference photo), and its footer names
HighWire<sup>TT</sup>. The logo (`html/images/logotst2.gif`) is the upstream logo inverted to amber on black, with a
small superscript TT after "HighWire" (0.4.8-sam4; operator review 2026-10-17). Not relabelled: the RSC menu-bar title, which is binary resource data.

## Why a proxy and not TLS on the TT

Measured on the TT (2026-10-17):
- **TLS on the 68030** (Mbed TLS 3.6.6): 19–26 s per TLS 1.3 handshake. Decryption runs at 6 KB/s with AES-GCM and
  24 KB/s with ChaCha20.
- **Through a TLS-terminating proxy** on the LAN, a 200 KB page arrives in 4–5 s.
- **On the ATW800/2's T425 transputer**, only X25519 can be offloaded, which saves about 27 % of the handshake.

HighWire 0.4.8 was already designed for this: with `HTTP_PROXY` set it sends `GET https://…` to the proxy.

## Upstream fixes

`packaging/upstream-sync.sh SIDE_REPO` lists upstream commits not yet in `sam-tt030`. With `--merge`, it test-merges
them on `upstream-eval/<date>` and builds. Each merge is tested on the TT before `sam-tt030` moves and `-samN` is
bumped. Packaging into the TT's yum mirror lives in the SAM side repo (`scripts/build_highwire_rpm.sh`).
