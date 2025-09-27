# Invidious Helm Chart

This guide explains how to deploy Invidious to Kubernetes using the Invidious Helm chart.

This chart is designed to be compatible with the Invidious Docker Compose template and follows the same security and configuration practices.

## Docker Compose Compatibility

This chart includes configurations that mirror the Docker Compose setup:

- **Same image versions**: Uses `quay.io/invidious/invidious:2025.09.24-42d34cd` and `quay.io/invidious/invidious-companion:master-a866b71`
- **Security settings**: Implements `cap_drop: ALL`, `read_only: true`, and `no-new-privileges` equivalent
- **Health checks**: Uses the same `wget` command for health verification
- **Logging**: Configured with equivalent log rotation settings
- **PostgreSQL 17**: Same database version as Docker Compose

For Docker Compose compatible configuration, use the provided `values-docker-compose-compat.yaml` file.

## Installing

Follow these steps to install the Helm chart:

1. Add the Invidious Helm chart repository:

   ```sh
   $ helm repo add invidious https://charts-helm.invidious.io
   $ helm repo update
   ```

2. Install the Helm chart to your Kubernetes cluster:

   ```sh
   $ helm install invidious invidious/invidious
   ```

## Upgrading

To upgrade the Helm chart, run the following command:

```sh
$ helm upgrade invidious invidious/invidious
```

## Uninstalling

To uninstall the Helm chart and remove all associated resources (except the database), execute:

```sh
$ helm delete invidious
```

### Removing `invidious-postgresql` PersistentVolumeClaims

> [!CAUTION]
> This action is irreversible. Ensure you have backed up any important data before proceeding.

If you want to delete the Invidious PostgreSQL database along with the Helm chart, you need to remove the associated [PersistentVolumeClaims (PVCs)](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#persistentvolumeclaims). Deleting the PVCs will permanently remove the persistent storage used by the database.

To delete the Invidious PostgreSQL database and its associated PVCs, run the following command:

```sh
$ kubectl delete pvc data-invidious-postgresql-0
```
