kubectl apply -f .\ServiceAccount_LoadBalancer.yml

helm repo add eks https://aws.github.io/eks-charts

helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=parktoken-production --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller

kubectl apply -f .\cluster-autoscaler-autodiscover.yml

# make sure these get added to cluster-autoscaler-autodiscover.yml
kubectl annotate serviceaccount cluster-autoscaler -n kube-system eks.amazonaws.com/role-arn=arn:aws:iam::700632024770:role/AmazonEKSClusterAutoScalerRole
kubectl patch deployment cluster-autoscaler -n kube-system -p '{"spec":{"template":{"metadata":{"annotations":{"cluster-autoscaler.kubernetes.io/safe-to-evict": "false"}}}}}'




Write-Warning "@ Record for parktoken.com is pointing to a static IP on the production load balancer."
Write-Warning "This needs to get moved or replaced as soon as possible!"




kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

## - deploy applications
Write-Host "You're ready to deploy applications now."