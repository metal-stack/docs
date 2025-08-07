# Cryptography

metal-stack incorporates multiple layers of cryptographic protection and secure communication to ensure system integrity and confidentiality:

### TLS Certificate Management

TLS certificates used by metal-stack components - as outlined in the [architecture section](../../concepts/architecture.md) - can be generated using either RSA 4096-bit or ECDSA 256-bit keys. We recommend RSA 4096.

By default, in-cluster communication is not encrypted. If encryption is required within the cluster, it must be configured manually using a service mesh (e.g., Istio or Linkerd) or a similar mechanism.
For outbound traffic, we recommend integrating cert-manager in combination with Let's Encrypt to handle certificate issuance and enable automated certificate rotation for ingress domains. In offline environments where Let's Encrypt cannot be used, the certificates must be issued and managed manually or via an internal CA.

### VPN & Network Encryption

metal-stack employs WireGuard-based VPN technology, orchestrated via Headscale. WireGuard leverages Elliptic Curve Cryptography (ECC) for key exchange and relies on the Noise Protocol Framework to establish secure and lightweight cryptographic handshakes.

### Authentication with JWT

Access to the `metal-api` is protected using JWT (JSON Web Tokens). These tokens are generated and verified using the [`go-jose`](https://github.com/go-jose/go-jose) library, which implements JOSE standards.

Supported signature algorithms include:

- RSA (RS256, RS384, RS512)
- RSA-PSS (PS256, PS384, PS512)
- ECDSA (ES256, ES384, ES512)
- EdDSA
