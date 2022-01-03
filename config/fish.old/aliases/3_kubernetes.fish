#!/usr/bin/env fish
curl -sL https://raw.githubusercontent.com/evanlucas/fish-kubectl-completions/master/completions/kubectl.fish -o ~/.config/fish/completions/kubectl.fish

alias kx kubectx
alias kn kubens

alias k kubectl
alias sk 'kubectl -n kube-system'
alias kg 'kubectl get'
alias kgp 'kubectl get po'
alias kga 'kubectl get --all-namespaces'
alias kd 'kubectl describe'
alias kdp 'kubectl describe po'
alias krm 'kubectl delete'
alias ke 'kubectl edit'
alias kex 'kubectl exec -it'
alias kdebug 'kubectl run -i -t debug --rm --image=caarlos0/debug --restart=Never'
alias knrunning 'kubectl get pods --field-selector=status.phase!=Running'
alias kfails 'kubectl get po -owide --all-namespaces | grep "0/" | tee /dev/tty | wc -l'
alias kimg "kubectl get deployment --output=jsonpath='{.spec.template.spec.containers[*].image}'"
alias kvs "kubectl view-secret"
alias kgno 'kubectl get no --sort-by=.metadata.creationTimestamp'
alias kdrain 'kubectl drain --ignore-daemonsets --delete-local-data'
