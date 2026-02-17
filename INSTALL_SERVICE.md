# Installing the Kubernetes Dashboard Port Forward Service

## Prerequisites
- The script must be executable
- You need sudo access to install systemd services

## Installation Steps

### 1. Make the script executable
```bash
chmod +x /home/migtronix/ansible/ai-workloads/devops/k8dashboard-port-forward.sh
```

### 2. Copy the service file to systemd directory
```bash
sudo cp /home/migtronix/ansible/ai-workloads/devops/k8s-dashboard-portforward.service /etc/systemd/system/
```

### 3. Reload systemd to recognize the new service
```bash
sudo systemctl daemon-reload
```

### 4. Enable the service to start on boot
```bash
sudo systemctl enable k8s-dashboard-portforward.service
```

### 5. Start the service
```bash
sudo systemctl start k8s-dashboard-portforward.service
```

## Managing the Service

### Check service status
```bash
sudo systemctl status k8s-dashboard-portforward.service
```

### View service logs
```bash
# View recent logs
sudo journalctl -u k8s-dashboard-portforward.service

# Follow logs in real-time
sudo journalctl -u k8s-dashboard-portforward.service -f

# View logs from last boot
sudo journalctl -u k8s-dashboard-portforward.service -b
```

### Stop the service
```bash
sudo systemctl stop k8s-dashboard-portforward.service
```

### Restart the service
```bash
sudo systemctl restart k8s-dashboard-portforward.service
```

### Disable the service from starting on boot
```bash
sudo systemctl disable k8s-dashboard-portforward.service
```

## Troubleshooting

If the service fails to start:

1. Check the service status for error messages:
   ```bash
   sudo systemctl status k8s-dashboard-portforward.service
   ```

2. Check the logs:
   ```bash
   sudo journalctl -u k8s-dashboard-portforward.service -n 50
   ```

3. Verify the script path is correct in the service file

4. Ensure the user has proper permissions to run kubectl

5. Verify KUBECONFIG environment variable points to the correct config file
