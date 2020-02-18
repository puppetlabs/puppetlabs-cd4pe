#!/bin/sh

set -e

src_dir_files='/etc/puppetlabs/cd4pe'
src_dir_object_store='/var/lib/docker/volumes/cd4pe-object-store'
# timestamp date for target filename
bkp_name="cd4pe_backup_$(date -I)"
dst_tmp_dir="/tmp/cd4pe_backups/${bkp_name}"

# create tmp dir & target dir
mkdir -p "${dst_tmp_dir}"
mkdir -p "${PT_target_dir}"

# get required disk space
used_k_files=$(du $src_dir_files -d 0 | tail -1 | awk '{print $1}')
used_k_object_store=$(du $src_dir_object_store -d 0 | tail -1 | awk '{print $1}')
used_b_db=$(sudo -u pe-postgres /opt/puppetlabs/server/bin/psql -t -d cd4pe  -c "SELECT pg_database_size('cd4pe') ;")
used_k_db="$((used_b_db/1000))" # hypothetical, pg_dump uses compression, but assuming no compression is safer than nothing
used_k_total="$(($used_k_files+$used_k_object_store+$used_k_db))"

# fail if required disk space is not available
k_free=$(df -P $PT_target_dir | tail -1 | awk '{print $4}')

if [ "$used_k_total" -lt "$k_free" ]; then
  echo "Backing up to target: ${PT_target_dir} - Available: ${k_free}K, required: db=~${used_k_db}K, files=${used_k_files}K, object_store=${used_k_object_store}K, total=~${used_k_total}K"
else
  echo "Aborting: Insufficient space available in: ${PT_target_dir} - Availabe: ${k_free}K, required: db=~${used_k_db}K, files=${used_k_files}K, object_store=${used_k_object_store}K, total=~${used_k_total}K"
  exit 1
fi

# Stop the container
echo "Stopping service: ${PT_service_name}"
systemctl stop $PT_service_name

if [ "$PT_manage_puppet_service" == "true" ]; then
  # Stop puppet service
  echo "Temporarily disabling Puppet agent"
  puppet agent --disable 'Running cd4pe backup' 
fi

# Archive /etc/puppetlabs/cd4pe
echo "Backing up: ${src_dir_files}"
cp -r --parents $src_dir_files "${dst_tmp_dir}/."

# Archive the cd4pe object store
echo "Backing up: ${src_dir_object_store}"
cp -r --parents $src_dir_object_store "${dst_tmp_dir}/."

# Dump the cd4pe database
echo "Backing up: db"
sudo -u pe-postgres /opt/puppetlabs/server/bin/pg_dump cd4pe > "${dst_tmp_dir}/cd4pe.sql"

# create tarball
echo "Creating archive ${PT_target_dir}/${bkp_name}.tar.gz"
rm -f "${PT_target_dir}/${bkp_name}.tar.gz"
tar -czf "${PT_target_dir}/${bkp_name}.tar.gz" -C ${dst_tmp_dir} .

# Start the container back up
echo "Starting service: ${PT_service_name}"
systemctl start $PT_service_name

if [ "$PT_manage_puppet_service" == "true" ]; then
  # Start puppet service
  echo "Enabling Puppet agent"
  puppet agent --enable
fi

# cleanup tmp dir
echo "Cleaning up tmp files: /tmp/cd4pe_backups/${bkp_name}"
rm -rf "/tmp/cd4pe_backups/${bkp_name}"

# clean-up backups older than retention period
echo "Cleaning up backups older than ${PT_retention_period_days} days"
find "${PT_target_dir}" -name "cd4pe_backup*.tar.gz" -type f -mtime +$PT_retention_period_days -exec rm -f {} \;

echo "Backup complete."
echo "${PT_target_dir}/${bkp_name}.tar.gz"
