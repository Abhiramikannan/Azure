1. ClusterIP
  Default service type, accessible only within the cluster.
  Has an internal cluster IP address and a port.
  Ports:
    Port (ClusterIP port) — the port exposed by the service inside the cluster.
    TargetPort — port on the application (pod).
    If port and targetPort are the same, specify only one (usually just port).
  Selector: maps service to pods by matching labels (only pods with matching labels receive traffic).
  Access inside cluster:
    curl clusterIP:port works.
    If targetPort differs (e.g., ClusterIP port 8080, but app listens on 80), curl clusterIP won't work unless correct port is specified.

2. NodePort
  Exposes the service outside the cluster, on each node’s IP at a static port (nodePort).
  Runs on a port between 30000-32767 by default (can be customized).
  Service has 3 ports:
      nodePort (external port on each node)
      port (ClusterIP port)
      targetPort (pod/application port)
nodePort is optional in the manifest (if omitted, a port in default range is assigned).
port is mandatory.
Must specify type: NodePort in the service manifest; otherwise defaults to ClusterIP.
Access:
Browser or external client can access via NodeIP:nodePort (ensure firewall/security groups allow inbound to nodePort).

3. LoadBalancer
    Exposes service externally using a cloud provider’s load balancer.
    Automatically creates a NodePort service as backend.
    Service type: LoadBalancer (instead of ClusterIP or NodePort).
    Assigns an external IP accessible from outside the cluster (e.g., internet).
    LoadBalancer forwards external traffic to the nodePort internally.
    Problem: Each service creates its own load balancer (can be costly, inefficient).
    Use Ingress to solve this.

4. Ingress
      Acts as a single entry point to multiple services.
      Provides path-based routing (e.g., /login forwards to service A, /api forwards to service B).
      Can route requests based on URL paths to different services running on nodePorts.
      Has an internal IP (cluster IP) and can be exposed externally with a public IP.
      Allows consolidation of load balancer resources by managing multiple services behind one external IP.

   ![image](https://github.com/user-attachments/assets/8c04d6f0-b5bf-42d6-9a3f-9d824977d13c)

5. REVERSE PROXY:
   
    Nginx: Reverse Proxy
   
    Used inside company networks with many backend servers.
    Acts as a traffic transmitter — forwards client requests to appropriate servers.
    Performs SSL termination (decrypts HTTPS requests before passing them on).
    Works with Ingress rules:
    Receives requests, matches them to ingress paths/rules, then routes accordingly.

6. Internal Load Balancer in Kubernetes:
   
      Regardless of service type (ClusterIP, NodePort, LoadBalancer), the internal load balancing within the cluster is always done by the ClusterIP service.
      So, traffic distribution inside the cluster happens via ClusterIP, no matter how the service is exposed externally.
