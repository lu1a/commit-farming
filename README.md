# commit-farming

If you've found this repo because I showed up on some commit-based ranking, then I've now shown you that ranking people by amount of commits is totally useless.

## Installation

Assuming running as root on a systemd-based server:

```
cp commit-farming-service-template.service /etc/systemd/system/commit-farming.service
cp commit-farming-timer-template.timer /etc/systemd/system/commit-farming.timer
systemd-analyze verify /etc/systemd/system/commit-farming.*
systemctl start commit-farming.timer
systemctl enable commit-farming.timer
```
