#!/bin/bash
# Infrastructure Deployer
# Automated setup for redirectors, C2 infrastructure, and red team ops

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ANSIBLE_DIR="${SCRIPT_DIR}/config/deploy/ansible"
TERRAFORM_DIR="${SCRIPT_DIR}/config/deploy/terraform"

banner() {
    echo -e "${CYAN}"
    cat << 'EOF'
╔═══════════════════════════════════════════════════════════╗
║         INFRASTRUCTURE DEPLOYER                          ║
║         Redirectors • C2 • Red Team Ops                  ║
╚═══════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Check prerequisites
check_prereqs() {
    echo -e "${BLUE}[*] Checking prerequisites...${NC}"
    
    local missing=()
    
    if ! command -v terraform &> /dev/null; then
        missing+=("terraform")
    fi
    
    if ! command -v ansible-playbook &> /dev/null; then
        missing+=("ansible")
    fi
    
    if ! command -v aws &> /dev/null; then
        missing+=("aws-cli")
    fi
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo -e "${YELLOW}[!] Missing tools: ${missing[*]}${NC}"
        echo -e "${YELLOW}[!] Install with: apt install terraform ansible awscli${NC}"
    else
        echo -e "${GREEN}[+] All prerequisites met${NC}"
    fi
}

# Deploy redirector
deploy_redirector() {
    local type="$1"
    local c2_host="$2"
    local c2_port="$3"
    
    echo -e "${BLUE}[*] Deploying $type redirector${NC}"
    echo -e "${BLUE}[*] C2: $c2_host:$c2_port${NC}"
    
    case "$type" in
        nginx)
            cat > redirector-nginx.conf << EOF
server {
    listen 80;
    server_name _;
    
    location / {
        proxy_pass http://$c2_host:$c2_port;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF
            echo -e "${GREEN}[+] Created nginx.conf for redirector${NC}"
            ;;
        socat)
            echo "socat TCP-LISTEN:80,fork TCP:$c2_host:$c2_port" > socat-redir.sh
            chmod +x socat-redir.sh
            echo -e "${GREEN}[+] Created socat-redir.sh${NC}"
            ;;
        iptables)
            cat > iptables-redir.sh << EOF
#!/bin/bash
# Redirector iptables rules
iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination $c2_host:$c2_port
iptables -t nat -A POSTROUTING -j MASQUERADE
EOF
            chmod +x iptables-redir.sh
            echo -e "${GREEN}[+] Created iptables-redir.sh${NC}"
            ;;
        *)
            echo -e "${RED}[!] Unknown redirector type: nginx, socat, iptables${NC}"
            ;;
    esac
}

# Setup C2 redirector with Terraform
setup_c2_terraform() {
    local c2_domain="$1"
    local listener_port="${2:-443}"
    
    echo -e "${BLUE}[*] Setting up C2 infrastructure with Terraform${NC}"
    
    cat > main.tf << EOF
# C2 Infrastructure - Terraform
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "c2_redirector" {
  ami           = "ami-0c02fb55956c7d315"
  instance_type = "t2.micro"
  
  tags = {
    Name        = "C2-Redirector"
    Environment = "RedTeam"
  }
  
  user_data = <<-EOF
#!/bin/bash
apt update
apt install -y nginx socat
cat > /etc/nginx/sites-available/redirector <<-NGINX
server {
    listen 80;
    server_name $c2_domain;
    location / {
        proxy_pass http://$c2_domain:$listener_port;
        proxy_set_header Host \$host;
        proxy_set_header X-Forwarded-For \$remote_addr;
    }
}
NGINX
ln -sf /etc/nginx/sites-available/redirector /etc/nginx/sites-enabled/
systemctl restart nginx
EOF
}

output "instance_ip" {
  value = aws_instance.c2_redirector.public_ip
}
EOF
    
    echo -e "${GREEN}[+] Created main.tf for C2 infrastructure${NC}"
    echo -e "${YELLOW}[*] Run: terraform init && terraform apply${NC}"
}

# Setup Ansible for redirector
setup_redirector_ansible() {
    local target="$1"
    local c2_ip="$2"
    local c2_port="$3"
    
    echo -e "${BLUE}[*] Creating Ansible playbook for redirector${NC}"
    
    cat > redirector.yml << EOF
---
- name: Setup C2 Redirector
  hosts: redirectors
  become: yes
  vars:
    c2_ip: $c2_ip
    c2_port: $c2_port
  
  tasks:
    - name: Install nginx
      apt:
        name: nginx
        state: present
    
    - name: Configure nginx redirector
      template:
        src: templates/nginx.conf.j2
        dest: /etc/nginx/sites-available/redirector
      notify: Restart nginx
    
    - name: Enable nginx redirector
      file:
        src: /etc/nginx/sites-available/redirector
        dest: /etc/nginx/sites-enabled/redirector
        state: link
      notify: Restart nginx
    
    - name: Setup socat backup
      copy:
        content: |
          #!/bin/bash
          socat TCP-LISTEN:80,fork TCP:{{ c2_ip }}:{{ c2_port }}
        dest: /opt/redirector.sh
        mode: +x
      cron:
        name: "Start redirector"
        job: "/opt/redirector.sh"
        state: present
    
    - name: Flush handlers
      meta: flush_handlers
  
  handlers:
    - name: Restart nginx
      service:
        name: nginx
        state: restarted
EOF
    
    cat > templates/nginx.conf.j2 << EOF
server {
    listen 80;
    server_name _;
    
    location / {
        proxy_pass http://{{ c2_ip }}:{{ c2_port }};
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_buffering off;
    }
}
EOF
    
    echo -e "${GREEN}[+] Created redirector.yml playbook${NC}"
    echo -e "${YELLOW}[*] Run: ansible-playbook -i $target, redirector.yml${NC}"
}

# Setup Empire/C2 profiles
setup_c2_profile() {
    local domain="$1"
    local port="${2:-443}"
    
    echo -e "${BLUE}[*] Creating C2 HTTP profile${NC}"
    
    cat > http_profile.py << EOF
#!/usr/bin/env python3
"""
C2 HTTP Profile Generator
Generates redirect rules for C2 communication
"""

http_profile = {
    "/": {
        "server": "nginx/1.18.0",
        "headers": {
            "Server": "nginx",
            "Content-Type": "text/html",
            "Connection": "keep-alive"
        },
        "behavior": {
            "kill_date": "2025-12-31",
            "jitter": 5,
            "connect_interval": 60
        }
    },
    "/api/login": {
        "server": "nginx",
        "headers": {
            "Content-Type": "application/json"
        },
        "response": {
            "status": 200,
            "body": {"success": False, "message": "Invalid credentials"}
        }
    }
}

# Generate nginx config
nginx_config = f"""
server {{
    listen {port};
    server_name {domain};
    
    location / {{
        proxy_pass http://127.0.0.1:{port+1};
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $remote_addr;
    }}
}}
"""

print("C2 Profile generated for:", domain)
print("Nginx config:", nginx_config)
EOF
    
    echo -e "${GREEN}[+] Created http_profile.py${NC}"
}

# Show usage
usage() {
    cat << 'EOF'
USAGE:
    ./infra-deployer.sh [OPTIONS]

OPTIONS:
    --check              Check prerequisites
    --redirector TYPE    Setup redirector (nginx/socat/iptables)
    --c2 DOMAIN          Setup C2 infrastructure (Terraform)
    --ansible TARGET     Create Ansible playbook for redirector
    --profile DOMAIN     Generate C2 HTTP profile
    -h, --help          Show this help

EXAMPLES:
    # Check prerequisites
    ./infra-deployer.sh --check

    # Setup nginx redirector
    ./infra-deployer.sh --redirector nginx --target 10.10.10.5 --c2 192.168.1.100 --port 443

    # Setup C2 infrastructure with Terraform
    ./infra-deployer.sh --c2 redirector.example.com --port 443

    # Create Ansible playbook
    ./infra-deployer.sh --ansible 192.168.1.5 --c2 10.10.10.100 --port 443

    # Generate C2 profile
    ./infra-deployer.sh --profile teamserver.example.com

EOF
}

main() {
    local action="menu"
    local type=""
    local target=""
    local c2_ip=""
    local c2_port="443"
    local domain=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --check) action="check" ;;
            --redirector) type="$2"; shift ;;
            --c2) domain="$2"; shift ;;
            --ansible) target="$2"; shift ;;
            --c2-ip) c2_ip="$2"; shift ;;
            --c2-port) c2_port="$2"; shift ;;
            --profile) domain="$2"; shift ;;
            -h|--help) action="help" ;;
            *) 
                if [[ -z "$domain" ]]; then domain="$1";
                elif [[ -z "$target" ]]; then target="$1";
                fi
                ;;
        esac
        shift
    done
    
    banner
    
    case "$action" in
        check)
            check_prereqs
            ;;
        redirector)
            if [[ -n "$type" && -n "$c2_ip" ]]; then
                deploy_redirector "$type" "$c2_ip" "$c2_port"
            else
                echo -e "${RED}[!] Type and C2 IP required${NC}"
            fi
            ;;
        c2)
            if [[ -n "$domain" ]]; then
                setup_c2_terraform "$domain" "$c2_port"
            else
                echo -e "${RED}[!] Domain required${NC}"
            fi
            ;;
        ansible)
            if [[ -n "$target" && -n "$c2_ip" ]]; then
                setup_redirector_ansible "$target" "$c2_ip" "$c2_port"
            else
                echo -e "${RED}[!] Target and C2 IP required${NC}"
            fi
            ;;
        profile)
            if [[ -n "$domain" ]]; then
                setup_c2_profile "$domain" "$c2_port"
            else
                echo -e "${RED}[!] Domain required${NC}"
            fi
            ;;
        help)
            usage
            ;;
        *)
            usage
            ;;
    esac
}

main "$@"
