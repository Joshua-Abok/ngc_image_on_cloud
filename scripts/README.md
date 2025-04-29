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


