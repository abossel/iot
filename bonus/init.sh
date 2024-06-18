kubectl create ns gitlab
kubectl config set-context --current --namespace=gitlab

helm repo add gitlab https://charts.gitlab.io
helm repo update

helm install gitlab gitlab/gitlab \
    --set global.hosts.domain=example.com \
    --set certmanager-issuer.email=me@example.com \
    --namespace gitlab

helm install gitlab gitlab/gitlab \
    --set global.hosts.domain=example.com \
    --set certmanager.install=false \
    --set global.ingress.configureCertmanager=false \
    --set global.ingress.tls.secretName=tls-certs \
    --namespace gitlab

sleep 5
kubectl wait pods -n gitlab --all --for condition=Ready --timeout=-1s


kubectl config set-context --current --namespace=default