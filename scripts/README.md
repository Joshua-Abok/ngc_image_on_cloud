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

## 3. Tear down the VM when done

```bash
./delete_instance.sh ml-spot-v100 us-central1-a
```



