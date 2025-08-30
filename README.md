# Docker DevSecOps Pipeline (v0.1.0)

End-to-end supply-chain security for Docker images, automated with GitHub Actions.
It includes OPA/Conftest, Trivy (FS + Image), CycloneDX SBOM (Syft), publish to GHCR, Cosign OIDC keyless signing + SBOM attestation (both verified in CI), OWASP ZAP DAST (gate on Medium/High), and strict runtime hardening.

Repo: https://github.com/Matiaslb14/docker-devsecops-pipeline

Image: ghcr.io/matiaslb14/notes-api:latest

⚡ Quick start
# Run from GHCR
docker run --rm -p 8080:8000 ghcr.io/matiaslb14/notes-api:latest
curl -s http://localhost:8080/

🔐 What the pipeline does

Policies (OPA/Conftest): checks compose.yml before building.

Scanning (Trivy):

FS (repo) and Image (image.tar) — pipeline fails on CRITICAL/HIGH.

SBOM (Syft → CycloneDX): writes reports/sbom.cdx.json.

Publish to GHCR: tags :latest, :{sha}, and :vX.Y.Z when pushed by tag.

Signing (Cosign OIDC keyless): signs images.

Attestation (Cosign): attaches CycloneDX SBOM → verified in CI.

DAST (OWASP ZAP): JSON/HTML report and gate if there are Medium/High alerts.

Artifacts: uploaded under security-reports/.

🛡️ Runtime hardening

user: "10001:10001" (non-root)

cap_drop: ["ALL"]

read_only: true

tmpfs for /tmp

security_opt: ["no-new-privileges:true", "seccomp:./docker/seccomp.json"]

The seccomp profile is downloaded from Docker/Moby and mounted explicitly.

▶️ Local run (hardened release compose)
docker compose -f compose.release.yml up -d
curl -s http://localhost:8080/

🖊️ Verify signature & SBOM attestation (local)
# Requires cosign (v2.x). If the image is private, docker login ghcr.io first.
export COSIGN_EXPERIMENTAL=1
IMG=ghcr.io/matiaslb14/notes-api:latest

# Signature (strict issuer + repo identity)
cosign verify \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com \
  --certificate-identity-regexp 'https://github\.com/Matiaslb14/docker-devsecops-pipeline/.*' \
  "$IMG"

# SBOM attestation (CycloneDX)
cosign verify-attestation --type cyclonedx \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com \
  --certificate-identity-regexp 'https://github\.com/Matiaslb14/docker-devsecops-pipeline/.*' \
  "$IMG" | head -n 20

🧱 Project structure
app/                # Minimal FastAPI app
docker/
  Dockerfile
  conftest/         # OPA (Rego) policies
  seccomp.json      # Seccomp profile (downloaded)
compose.yml         # Dev stack
compose.release.yml # Hardened release stack
.github/workflows/
  ci.yml            # build → scans → SBOM → push → sign → attest → verify
  zap.yml           # ZAP DAST + gate Medium/High

🌎 Why this repo

Demonstrates shift-left security in a real CI/CD flow.

Produces signed & scanned artifacts with a verifiable SBOM.

Enforces least privilege at runtime by default.
