Deploy Azure Resources
```bash
cd azure
./deployAzureResources.sh <subscriptionName>
```

Connect to Azure VM
```bash
cd ..
cd kubernetes
./connectToVM.sh
```

Clone GitHub Repository
```bash
git clone https://github.com/Evilazaro/cka.git
```

Grant scripts permition
```bash 
cd cka
find . -exec chmod +x {} \;
```
Install Kubernetes Cluster
```bash
cd kubernetes
./createKubernetesCluster.sh
```