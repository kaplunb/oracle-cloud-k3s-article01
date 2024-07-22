output "control_plane_user_data" {
  description = "User data and public IP for the control plane node"
  value = {
    node_name = oci_core_instance.k3s_control_plane.display_name
    public_ip = oci_core_instance.k3s_control_plane.public_ip
    private_ip = oci_core_instance.k3s_control_plane.private_ip
    user_data = base64decode(oci_core_instance.k3s_control_plane.metadata.user_data)
  }
}

output "worker_arm_user_data" {
  description = "User data and public IPs for the ARM worker nodes"
  value = {
    for idx, instance in oci_core_instance.k3s_worker_arm :
    format("worker-arm-%d", idx) => {
      node_name = instance.display_name
      public_ip = instance.public_ip
      private_ip = instance.private_ip
      user_data = base64decode(instance.metadata.user_data) 
    }
  }
}

output "worker_x86_user_data" {
  description = "User data and public IPs for the x86 worker nodes"
  value = {
    for idx, instance in oci_core_instance.k3s_worker_x86 :
    format("worker-x86-%d", idx) => {
      node_name = instance.display_name
      public_ip = instance.public_ip
      private_ip = instance.private_ip
      user_data = base64decode(instance.metadata.user_data)
    }
  }
}
