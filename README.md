```sh
# prepare
$ ./install-dependencies.sh
# start
$ ./bin/minikube start --nodes 3 -p multinodes
$ ./bin/minikube addons enable metallb -p multinodes
$ ./bin/minikube ip -p multinodes
$ ./bin/minikube addons configure metallb -p multinodes
# install
$ ./bin/terraform fmt && ./bin/terraform init && ./bin/terraform apply
# stop
$ ./bin/minikube stop -p multinodes
# clean all
$ ./bin/minikube delete -p multinodes
```