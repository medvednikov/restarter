To install:

```bash
  # Edit the ExecStart line with your actual arguments
  sudo cp restarter.service /etc/systemd/system/
  sudo systemctl daemon-reload
  sudo systemctl enable restarter.service  # Enable on boot
  sudo systemctl start restarter.service   # Start now
```

  You'll need to update the ExecStart line with your actual website, word, and service name.
