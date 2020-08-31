# Kubernetes

## Control Plane Components

* **Control plane** components can be run on any machine in the cluster. However, for simplicity, set up scripts typically start all control plane components on the same machine, and do not run user containers on this machine
  * **kube-apiserver**
    * Exposes the Kubernetes API
    * can be scaled horizontally by running multiple instances and balancing traffic between those instances
  * **etcd**
    * Consistent and highly-available key value store used as Kubernetes' backing store for all cluster data
    * Recommended to have a backup plan for the data
  * **kube-scheduler**
    * Watches for newly created Pods with no assigned node, and selects a node for them to run on
  * **kube-controller-manager**
    * Control Plane component that runs controller processes
    * Monitors the shared cluster state through the api server and tries to moe the current state towards the desired state
    * Combines independent controller loops into a single binary
  * **cloud-controller-manager**
    * Runs controllers that are specific to your cloud provider
    * Separates out the components that interact with that cloud platform from components that just interact with your cluster
    * Not required in an on-premises cluster
    * Combines independent controller loops into a single binary

* **kube-controller-manager** control loops:
  * **Node Controller** - Responsible for noticing and responding when nodes go down
  * **Replication controller** - Responsible for maintaining the correct number of pods for every replication controller object in the system
  * **Endpoints controller** - Populates the Endpoints object (that is, joins Services & Pods)
  * **Service Account & Token controllers** - Create default accounts and API access tokens for new namespaces

## Node Components

* **kubelet**
  * Runs on each node
  * Takes a set of PodSpecs that are provided through various mechanisms and ensures that the containers described in those PodSpecs are running and healthy
* **kube-proxy**
  * Network proxy
  * Runs on each node
  * Maintains network rules (on nodes) that allow network communication to the Pods
* **Container runtime**
  * Responsible for running containers viz. Docker
  * Implementation of the Kubernetes CRI (Container Runtime Interface)

## Addons

* Addons use Kubernetes resources (DaemonSet, Deployment, etc) to implement cluster features
* Namespaced resources for addons belong within the kube-system namespace
* Some Addons
  * **DNS** - all Kubernetes clusters should have cluster DNS
  * **Web UI (Dashboard)** - a general purpose, web-based UI for Kubernetes clusters. It allows users to manage and troubleshoot applications running in the cluster, as well as the cluster itself
  * **Container Resource Monitoring** - records generic time-series metrics about containers in a central database, and provides a UI for browsing that data
  * **Cluster-level Logging** - mechanism is responsible for saving container logs to a central log store with search/browsing interface

## Primitives

* **Pod** - A Pod is an atomic unit of scheduling, deployment, and runtime isolation for a group of containers. All containers in a Pod are always scheduled to the same host, deployed together whether for scaling or host migration purposes, and can also share filesystem, networking, and process namespaces. This joint lifecycle allows the containers in a Pod to interact with each other over the filesystem or through networking via localhost or host interprocess communication mechanisms if desired (for performance reasons, for example)

* **Service** - In the most common scenario, the Service serves as the entry point for a set of Pods, but that might not always be the case. The Service is a generic primitive, and it may also point to functionality provided outside the Kubernetes cluster. As such, the Service primitive can be used for Service discovery and load balancing, and allows altering implementations and scaling without affecting Service consumers

* **Label** - Label selectors give us the ability to query and identify a set of Pods and manage it as one logical unit. These labels can be used by the scheduler for more fine-grained scheduling, or the same labels can be used from the command line for managing the matching Pods at scale. Removing labels is much riskier as there is no straight-forward way of finding out what a label is used for, and what unintended effect such an action may cause.

* **Annotation** - Annotations are intended for specifying nonsearchable metadata and for machine usage rather than human. Some examples of using annotations include build IDs, release IDs, image information, timestamps, Git branch names, pull request numbers, image hashes, registry addresses, author names, tooling information, and more.

* **Namespace** - Kubernetes namespaces allow dividing a Kubernetes cluster (which is usually spread across multiple hosts) into a logical pool of resources. Namespaces provide scopes for Kubernetes resources and a mechanism to apply authorizations and other policies to a subsection of the cluster. The most common use case of namespaces is representing different software environments such as development, testing, integration testing, or production. Namespaces can also be used to achieve multitenancy, and provide isolation for team workspaces, projects, and even specific applications. But ultimately, for a greater isolation of certain environments, namespaces are not enough, and having separate clusters is common. Typically, there is one nonproduction Kubernetes cluster used for some environments (development, testing, and integration testing) and another production Kubernetes cluster to represent performance testing and production environments.
  * A namespace provides scope for resources such as containers, Pods, Services, or ReplicaSets. The names of resources need to be unique within a namespace, but not across them
  * By default, namespaces provide scope for resources, but nothing isolates those resources and prevents access from one resource to another. For example, a Pod from a development namespace can access another Pod from a production namespace as long as the Pod IP address is known
  * Some other resources such as namespaces themselves, nodes, and PersistentVolumes do not belong to namespaces and should have unique cluster-wide names
  * Each Kubernetes Service belongs to a namespace and gets a corresponding DNS address that has the namespace
  * ResourceQuotas provide constraints that limit the aggregated resource consumption per namespace
  * List the available namespaces - `kubectl get namespaces`
  * Definition of development namespace
  ```
  {
    "apiVersion": "v1",
    "kind": "Namespace",
    "metadata": {
      "name": "development",
      "labels": {
        "name": "development"
      }
    }
  }
  ```
  * Create a new namespace - `kubectl create - f admin/namespace-dev.json`
  * List the namespaces along with their labels - `kubectl get namespaces --show-labels`


  

## QoS

* **Compressible** resources can be throttled e.g. cpu, network bandwidth
* **Incompressible** resources cannot be throttled e.g. memory
* Every container definition can specify:
  * **requests** - specify minimum amout of resources needed. It is used by the scheduler when placing pods to nodes
  * **limits** - maximum amount of resources needed
* **Quality of Services (QoS)** - 
  **Best Effort** - 
    * No **requests** or **limits** are specified
    * Lowest priority
    * First to be killed by kubelet when the node runs out of **incompressible** resources
  **Burstable** -
    * **requests** and **limits** are specified
    * **requests** and **limits** have unequal values
    * Have minimal resource guarantees but willing to consume more resources when available
    * Likely to be killed by kubelet when the node is under incompressible resource pressure and the no **Best Effort** pods are remaining
  **Guaranteed** -
    * **requests** and **limits** are specified
    * **requests** and **limits** have equal values
    * Highest priority
    * Guaranteed not to be killed before **Best Effort** and **Burstable** pods
    * Appropriate for production pods

## Pod Priority

* **Pod priority** allows indicating importance of a pod relative to others
* With pod priority enabled, scheduler places pod on nodes in order of priority
* If no nodes with enough capacity are available, scheduler removes pods with lower priority to place a pod with higher priority
* Scheduler does not consider the QoS while evicting lower priority pods
* While evicting lower priority pods, the scheduler does not guarantee the PodDisruptionBudget, which could break a lower-priority clustered application that relies on a quorum of Pods
* To prevent maliscious users from creating pods with a very high priority evicting all other critical pods, the administrators can enforce ResourceQuota reserving higher priority values for critical pods

## References

* Ibryam, Bilgin; Huß, Roland. Kubernetes Patterns (Kindle Locations 602-604). O'Reilly Media. Kindle Edition. 