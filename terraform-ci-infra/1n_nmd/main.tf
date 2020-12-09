# For convenience in simple configurations, a child module automatically
# inherits default (un-aliased) provider configurations from its parent.
# This means that explicit provider blocks appear only in the root module,
# and downstream modules can simply declare resources for that provider
# and have them automatically associated with the root provider
# configurations.
module "minio" {
  source                = "./minio"
  providers             = {
    nomad = nomad.yul1
  }

  # nomad
  nomad_datacenters     = [ "yul1" ]
  nomad_host_volume     = "prod-volume-data1-1"

  # minio
  minio_job_name        = "prod-minio"
  minio_group_count     = 4
  minio_service_name    = "storage"
  minio_host            = "http://10.32.8.1{4...7}"
  minio_port            = 9000
  minio_container_image = "minio/minio:RELEASE.2020-12-03T05-49-24Z"
  minio_vault_secret    = {
    use_vault_provider        = false,
    vault_kv_policy_name      = "kv-secret",
    vault_kv_path             = "secret/data/minio",
    vault_kv_field_access_key = "access_key",
    vault_kv_field_secret_key = "secret_key"
  }
  minio_data_dir        = "/data/"
  minio_use_host_volume = true
  minio_use_canary      = true
  minio_resource_proxy  = {
    cpu    = 200
    memory = 128
  }
  minio_envs            = [ "MINIO_BROWSER=\"off\"" ]

  # minio client
  mc_job_name           = "prod-mc"
  mc_container_image    = "minio/mc:RELEASE.2020-12-10T01-26-17Z"
  mc_extra_commands     = [
    "mc policy set public LOCALMINIO/logs.fd.io",
    "mc policy set public LOCALMINIO/docs.fd.io",
    "mc ilm add --expiry-days "180" LOCALMINIO/logs.fd.io",
    "mc admin user add LOCALMINIO storage Storage1234",
    "mc admin policy set LOCALMINIO writeonly user=storage"
  ]
  minio_buckets         = [ "logs.fd.io", "docs.fd.io" ]
}

module "nginx" {
  source                = "./nginx"
  providers             = {
    nomad = nomad.yul1
  }

  # nomad
  nomad_datacenters     = [ "yul1" ]

  # nginx
  nginx_job_name        = "prod-nginx"
}

#module "vpp_device" {
#  source = "./vpp_device"
#  providers = {
#    nomad = nomad.yul1
#  }
#}