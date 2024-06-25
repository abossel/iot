### useful command
- kubectl describe pod <pod-name>

### Note
- for p3, run the script from the srcipts dir

run to refesh port after editing the service
```
kubectl port-forward svc/wil42-playground -n dev 8888:8888 > /dev/null 2>&1 < /dev/null &
```

https://docs.gitlab.com/operator/installation.html
### due to gitlab not fully supporting kube 1.30 yet, we will be using 1.29.6 instead


### installing kubectl
```
curl -LO https://dl.k8s.io/release/v1.29.6/bin/linux/amd64/kubectl
curl -LO "https://dl.k8s.io/release/v1.29.6/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```
if no root
```
chmod +x kubectl
mkdir -p ~/.local/bin
mv ./kubectl ~/.local/bin/kubectl
# and then append (or prepend) ~/.local/bin to $PATH
```


https://forum.gitlab.com/t/installing-gitlab-on-local-kubernetes-cluster/66935

kubectl -n gitlab patch svc gitlab-nginx-ingress-controller -p '{"spec": {"type": "NodePort"}}'