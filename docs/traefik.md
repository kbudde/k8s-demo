# Traefik

## Traefik CRDs + External-DNS

Traefik CRDs are supported, but the CR is not updated with the service' ip. Therefore an additional annotation is needed and some preparation.

**IngressRoutes**

External-DNS supports Ingressroutes and reads the hostname from it's rules to create DNS records but it cannot read the target ip from the status field as for ingress (there is no status).

Option 1: Specify annotation `external-dns.alpha.kubernetes.io/target`  with the IP on each IngressRoute. As the IP is usually not known before creating the loadbalancer, this solution is not my preferred one.

Option 2: Specify a hostname to create a CNAME record.
Example: `external-dns.alpha.kubernetes.io/target: lb.demo.budd.ee`

The A record for `lb.demo.budd.ee` can be created automatically by annotating traefiks service.

**annotate traefiks service** (traefik setup)

To create an A record for traefiks lb, you must annotate the svc used by trafik with one hostname.
E.g. in helm:

```yaml
service:
  annotations: 
    external-dns.alpha.kubernetes.io/hostname: lb.demo.budd.ee
    kubernetes.io/ingress.class: traefik #! TODO: findout out why it's required
```

**enable traefik source (external-dns)**

```yaml
sources:
  - service
  - traefik-proxy
  - ingress # optional
```

The service of type LoadBalancer will be updated with the loadBalancer ip. External-DNS will create a DNS A-record.


source: <https://github.com/kubernetes-sigs/external-dns/pull/3055>