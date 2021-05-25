## Get helm repo
```
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```

## Helm install
```bash
helm show values \
  bitnami/airflow \
  --version 10.0.4 \
  > values.yaml

helm install airflow \
  bitnami/airflow \
  --version 10.0.4 \
  -f values.yaml,values-overwrite.yaml \
  -n airflow \
  --create-namespace
```

## Update
```bash
export AIRFLOW_PASSWORD=$(kubectl get secret --namespace "airflow" airflow -o jsonpath="{.data.airflow-password}" | base64 --decode)
export AIRFLOW_FERNETKEY=$(kubectl get secret --namespace "airflow" airflow -o jsonpath="{.data.airflow-fernetKey}" | base64 --decode)
export POSTGRESQL_PASSWORD=$(kubectl get secret --namespace "airflow" airflow-postgresql -o jsonpath="{.data.postgresql-password}" | base64 --decode)
export REDIS_PASSWORD=$(kubectl get secret --namespace "airflow" airflow-redis -o jsonpath="{.data.redis-password}" | base64 --decode)


helm upgrade airflow \
  bitnami/airflow \
  --version 10.0.4 \
  -n airflow \
  -f values.yaml,values-overwrite.yaml \
  --set auth.password=$AIRFLOW_PASSWORD \
  --set auth.fernetKey=$AIRFLOW_FERNETKEY \
  --set postgresql.postgresqlPassword=$POSTGRESQL_PASSWORD \
  --set redis.auth.password=$REDIS_PASSWORD
```

```
export AIRFLOW_PASSWORD=$(kubectl get secret --namespace "airflow" airflow -o jsonpath="{.data.airflow-password}" | base64 --decode)
echo User:     user
echo Password: $AIRFLOW_PASSWORD
```
