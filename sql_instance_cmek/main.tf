# [START cloud_sql_instance_service_identity]
resource "google_project_service_identity" "gcp_sa_cloud_sql" {
  provider = google-beta
  service  = "sqladmin.googleapis.com"
}
# [END cloud_sql_instance_service_identity]

# [START cloud_sql_instance_keyring]
resource "google_kms_key_ring" "keyring" {
  name     = "keyring-name"
  location = "us-central1"
}
# [END cloud_sql_instance_keyring]

# [START cloud_sql_instance_key]
resource "google_kms_crypto_key" "key" {
  name     = "crypto-key-name"
  key_ring = google_kms_key_ring.keyring.id
  purpose  = "ENCRYPT_DECRYPT"
}
# [END cloud_sql_instance_key]

# [START cloud_sql_instance_crypto_key]
resource "google_kms_crypto_key_iam_binding" "crypto_key" {
  crypto_key_id = google_kms_crypto_key.key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

  members = [
    "serviceAccount:${google_project_service_identity.gcp_sa_cloud_sql.email}",
  ]
}
# [END cloud_sql_instance_crypto_key]

# [START cloud_sql_mysql_instance_cmek]
resource "google_sql_database_instance" "mysql_instance_with_cmek" {
  name                = "mysql-instance-cmek"
  provider            = google-beta
  region              = "us-central1"
  database_version    = "MYSQL_8_0"
  encryption_key_name = google_kms_crypto_key.key.id
  settings {
    tier = "db-n1-standard-2"
  }
  deletion_protection =  "true"
}
# [END cloud_sql_mysql_instance_cmek]

# [START cloud_sql_postgres_instance_cmek]
resource "google_sql_database_instance" "postgres_instance_with_cmek" {
  name                = "postgres-instance-cmek"
  provider            = google-beta
  region              = "us-central1"
  database_version    = "POSTGRES_14"
  encryption_key_name = google_kms_crypto_key.key.id
  settings {
    tier = "db-custom-2-7680"
  }
  deletion_protection =  "true"
}
# [END cloud_sql_postgres_instance_cmek]

# [START cloud_sql_sqlserver_instance_cmek]
resource "google_sql_database_instance" "default" {
  name                = "sqlserver-instance-cmek"
  provider            = google-beta
  region              = "us-central1"
  database_version    = "SQLSERVER_2019_STANDARD"
  root_password       = "INSERT-PASSWORD-HERE "
  encryption_key_name = google_kms_crypto_key.key.id
  settings {
    tier = "db-custom-2-7680"
  }
  deletion_protection =  "true"
}
# [END cloud_sql_sqlserver_instance_cmek]
