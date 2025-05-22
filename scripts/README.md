## 1. Authenticate & set your project

```bash
# Log in (if you haven’t already)
gcloud auth login

# Pick your GCP project
gcloud config set project YOUR_PROJECT_ID
```

---

## 2. Create a GCS bucket (if you don’t already have one)

```bash
gsutil mb gs://<choose-globally-unique-name>

gsutil cp startup-script.sh gs://my-startup-scripts-123/
```

### ✅ Refactored & Scriptable Version (with optional startup script)

If you **don’t have a startup script**:
```bash
chmod +x create_ml_gpu_vm.sh
./create_spot_instance.sh ml-gpu-vm us-central1-b v100 <SERVICE_AC_NO> <YOUR_PROJECT_ID>
```

If you **do have a startup script uploaded to GCS**:
```bash
./create_spot_instance.sh ml-gpu-vm us-central1-b v100 <SERVICE_AC_NO> <YOUR_PROJECT_ID> gs://<choose-globally-unique-name>/startup-script.sh
```

Wait a minute for the VM to boot & startup script to run

You can watch serial logs to confirm the startup-script ran successfully:

```bash
gcloud compute instances get-serial-port-output ml-gpu-vm \
  --zone=us-central1-b
```

Scroll to the bottom—if you see “Startup script complete. Jupyter should be listening on port 8888.”, you’re good.

---

## 3. Skip Docker entirely and install/run Jupyter Lab natively on your GPU VM
>binding it to `0.0.0.0` so you can hit it via its public IP.

---

### A. Install Python & Jupyter Lab

SSH into your VM, then:

```bash
sudo apt-get update
sudo apt-get install -y python3-pip python3-venv
# (Optionally) create a virtualenv
python3 -m venv ~/jlab-venv
source ~/jlab-venv/bin/activate

# Install Jupyter Lab (and any other deps)
pip install --upgrade pip
pip install jupyterlab
```

---

### B. Generate a Jupyter config & password

1. **Create the config file**

   ```bash
   jupyter lab --generate-config
   # This creates ~/.jupyter/jupyter_lab_config.py
   ```

2. **Set a password** (so you won’t need the URL token each time)

   ```bash
   python3 - <<EOF
    from jupyter_server.auth import passwd
    print("Your Jupyter password hash:\n", passwd())
    EOF
   ```

   Copy the resulting hash (it looks like `sha1:...`).

3. **Edit** `~/.jupyter/jupyter_lab_config.py` and add these lines at the bottom:

   ```python
   c.ServerApp.ip = '0.0.0.0'                # listen on all interfaces
   c.ServerApp.port = 8888
   c.ServerApp.open_browser = False
   c.ServerApp.password = u'<PASTE_YOUR_HASH_HERE>'
   c.ServerApp.allow_root = True            # only if you’re root; omit if running as ubuntu
   c.ServerApp.disable_check_xsrf = True    # if you run behind a proxy; optional
   ```

   Save & exit.

---

### C. (Optional) Run Jupyter Lab in the background

#### i) Using `nohup`

```bash
# Activate your venv, if you made one:
source ~/jlab-venv/bin/activate

nohup jupyter lab \
  --config=~/.jupyter/jupyter_lab_config.py \
  > ~/jupyter.log 2>&1 &
```

Check with `ps aux | grep jupyter` and view logs in `~/jupyter.log`.

Then:

```bash
sudo systemctl daemon-reload
sudo systemctl enable jupyter
sudo systemctl start jupyter
sudo systemctl status jupyter
```

---

### D. Open the VM’s firewall for port 8888

If you haven’t already, create a GCP firewall rule allowing ingress on TCP 8888.

#### Via gcloud CLI

```bash
gcloud compute firewall-rules create allow-jupyter-8888 \
  --network default \
  --direction=INGRESS \
  --action=ALLOW \
  --rules=tcp:8888 \
  --source-ranges=0.0.0.0/0 \
  --target-tags=jupyter-server
```

Then tag your VM:

```bash
gcloud compute instances add-tags ml-gpu-vm \
  --zone=us-central1-b \   
  --tags=jupyter-server
```

#### Or via Console

1. Go to **VPC network > Firewall rules**.
2. **Create** a rule named `allow-jupyter-8888`, Direction: *Ingress*, Action: *Allow*, Targets: *Specified target tags* → `jupyter-server`, Source IP ranges: `0.0.0.0/0`, Protocols: `tcp:8888`.

---

### E. Browse to your notebook

Open your browser to

```
http://<VM_EXTERNAL_IP>:8888
```

and log in with the password you set.

---

That gives you a public‑IP‑accessible Jupyter Lab, no Docker required. 


## 4. Tear down the VM when done

```bash
./delete_instance.sh ml-spot-v100 us-central1-a
```


