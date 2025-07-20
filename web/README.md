# Passive Recon Notes

This repository contains modular scripts and notes for performing passive reconnaissance during web application penetration tests. Each script is scoped to a single recon task and can be used independently or chained together.

---

## DNSDumpster

**Website**: https://dnsdumpster.com  
**Description**: DNSDumpster is a free online DNS recon and research tool that can discover hosts related to a domain. It gathers passive DNS data, including subdomains, IPs, hostnames, and DNS records.

**Use Cases**:
- Enumerate subdomains passively
- Identify associated IP addresses
- Visualize the DNS infrastructure

**Usage**:  
DNSDumpster does not offer an official API. It should be used manually or with browser automation (if permitted by its terms of use). It enforces rate limits and bot protection.

---

## Shodan

**Website**: https://www.shodan.io  
**Description**: Shodan is a search engine for Internet-connected devices and services. It indexes metadata like service banners, open ports, software versions, and geolocation for hosts on the public internet.

**Use Cases**:
- Discover exposed services tied to a target
- Perform reconnaissance by domain, IP, or ASN
- Review historical exposure and known vulnerabilities (paid feature)

**Command-line Tool**:
Install:
```bash
pip install shodan

