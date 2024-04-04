cluster_name=my-cluster

message()
{
  echo -e "\033[1;35m${1}\033[0m"
}

message "Checking if cluster already exists..."
k3d cluster list | grep -q "$cluster_name"
if [ $? -eq 0 ]
then
  echo "Cluster '$cluster_name' already exists."
  exit
fi
echo "Cluster '$cluster_name' not found."

message "Creating cluster..."
k3d cluster create $cluster_name

message "Creating argocd namespace..."
kubectl create ns argocd

message "Installing cluster argo-cd..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

message "Waiting for argo-cd pods..."
sleep 5
kubectl get pods -n argocd | grep -q " *0/1 *"
while [ $? -eq 0 ]
do
  sleep 1
  kubectl get pods -n argocd | grep -q " *0/1 *"
done

message "Getting login info..."
argocd_password=`kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo`
echo URL: https://localhost:8080/
echo CLI: argocd login localhost:8080
echo Login: admin
echo Password: $argocd_password

message "Forwarding port for argo-cd..."
kubectl port-forward svc/argocd-server -n argocd 8080:443 > /dev/null 2>&1 < /dev/null &
echo PID: $!

message "Enabling API access..."
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

message "Creating dev namespace..."
kubectl create ns dev

message "Creating app from file..."
kubectl apply -n argocd -f ../conf/application.yaml

#message "Installing local argo-cd..."
#curl -sSL -o /tmp/argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
#sudo install -m 555 /tmp/argocd-linux-amd64 /usr/local/bin/argocd
#rm /tmp/argocd-linux-amd64

#message "Logging in..."
#argocd login --insecure --username admin --password $argocd_password localhost:8080

#message "Setting namespace to argocd..."
#kubectl config set-context --current --namespace=argocd

#message "Creating app from command line..."
#argocd app create wil42-playground --repo https://github.com/abossel/k3d-test.git --path dev --dest-server https://kubernetes.default.svc --dest-namespace dev

#message "Syncing app..."
#argocd app sync wil42-playground

message "Waiting for app pods..."
sleep 5
kubectl get pods -n dev | grep -q " *0/1 *"
while [ $? -eq 0 ]
do
  sleep 1
  kubectl get pods -n dev | grep -q " *0/1 *"
done

message "Getting app info..."
echo URL: http://localhost:8888/

message "Forwarding port for app..."
kubectl port-forward svc/wil42-playground -n dev 8888:8888 > /dev/null 2>&1 < /dev/null &
echo PID: $!
