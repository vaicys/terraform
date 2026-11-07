# MikroTik CHR image preparation for GCP
#
# 1. Download the "Raw disk image" (.img.zip) from https://mikrotik.com/download
#    (under Cloud Hosted Router -> Raw disk image):
#
#    wget https://download.mikrotik.com/routeros/7.24.6/chr-7.24.6.img.zip
#
# 2. Extract the raw image file:
#
#    unzip chr-7.24.6.img.zip
#
# 3. Rename the extracted file to `disk.raw` and resize/align it to a full GiB
#    boundary (GCE requires the raw image inside the archive to be named
#    `disk.raw` and have a size that is a multiple of 1 GiB):
#
#    mv chr-7.24.6.img disk.raw
#    truncate -s 1G disk.raw
#
# 4. Package `disk.raw` into a `.tar.gz` archive using the `oldgnu` tar format
#    (required by GCE image import):
#
#    tar --format=oldgnu -Sczf chr-7.24.6.tar.gz disk.raw

# variable "chr_image_file" {
#   description = "Local path to the prepared MikroTik CHR tar.gz image containing disk.raw"
#   type        = string
#   default     = "chr-7.24.6.tar.gz"
# }

# resource "google_storage_bucket" "chr_images" {
#   name                        = "${var.gcp_project_id}-mikrotik-chr-images"
#   location                    = var.gcp_region # us-east1 regional bucket qualifies for 5 GB Free Tier
#   storage_class               = "STANDARD"
#   uniform_bucket_level_access = true
#   force_destroy               = true
# }

# resource "google_storage_bucket_object" "chr_image_archive" {
#   name   = "chr-7.24.6.tar.gz"
#   bucket = google_storage_bucket.chr_images.name
#   source = var.chr_image_file
# }

# resource "google_compute_image" "mikrotik_chr" {
#   name   = "mikrotik-chr-7-24-6"
#   family = "mikrotik-chr"

#   raw_disk {
#     source = "https://storage.googleapis.com/${google_storage_bucket.chr_images.name}/${google_storage_bucket_object.chr_image_archive.name}"
#   }
# }
