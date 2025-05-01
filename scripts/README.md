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
```

### ✅ Refactored & Scriptable Version (with optional startup script)

If you **don’t have a startup script**:
```bash
chmod +x create_ml_gpu_vm.sh
./create_spot_instance.sh ml-gpu-vm us-central1-b <YOUR_PROJECT_ID>
```

If you **do have a startup script uploaded to GCS**:
```bash
./create_spot_instance.sh ml-gpu-vm us-central1-b <YOUR_PROJECT_ID> gs://<choose-globally-unique-name>/startup-script.sh
```

## 3. Tear down the VM when done

```bash
./delete_instance.sh ml-spot-v100 us-central1-a
```





