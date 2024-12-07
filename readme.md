# k8s-operator-workshop

Denne workshopen vil la deg øve deg på å lage en enkel Kubernete-operator. En operator kan defineres slik:
> A Kubernetes operator is a controller that automates the deployment and management of complex or stateful applications on Kubernetes. It uses a Custom Resource Definition (CRD) to define the desired state and continuously reconciles it with the actual state, handling tasks like scaling, upgrades, and backups automatically.

## Komme i gang

### Påkrevd programvare
- Go 1.23.4+
- Docker
- kubectl v1.31.0+
- kind
- IntelliJ IDEA / Goland / VSCode (anbefalt, men ikke påkrevd)

Hvis du kjører macOS kan du installere disse programmene med Homebrew:
```sh
# Fjern det du eventuelt har installert fra før
brew install go docker kind kubernetes-cli

# Nice to haves
brew install kubectx k9s kube-ps1 golangci-lint stern
```

## Instruksjoner

Selve instruksjonene for workshopen finner du her ➡️ [workshop.md](./workshop.md) ⬅️.
