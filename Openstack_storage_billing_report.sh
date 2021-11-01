#!/bin/bash
#
# Openstack billing report gnocchi storage dump to CSV
#

start_date=2021-10-01
end_date=2021-11-01

echo \"Project Name\",\"Project ID\",\"Volume Name\",\"Volume ID\",\"Volume State\",\"Volume Size GB\",\"Volume attached to\",\"Volume GB hours\"

for os_project_id in $(openstack project list -f value -c ID)
do
  os_project_name=$(openstack project show -f value -c name $os_project_id)
  while IFS="," read -r os_vol_id_in_project os_vol_name_in_project os_vol_status_in_project os_vol_size_in_project os_vol_attached_in_project
  do
    os_vol_gb_hours=$(eval openstack metric measures show -r $os_vol_id_in_project volume.size --granularity 300 --resample 3600 -f value -c value --start $start_date --stop $end_date | paste -sd+ - | bc)
    os_vol_attached_in_project_trimmed=$(eval echo $os_vol_attached_in_project | cut -c17-52)
#    os_vol_attached_in_project_trimmed=$(eval echo $os_vol_attached_in_project | sed 's/Attached to //' | sed 's/ on \/dev\/.*//')
    echo \"$os_project_name\",\"$os_project_id\",$os_vol_name_in_project,$os_vol_id_in_project,$os_vol_status_in_project,$os_vol_size_in_project,$os_vol_attached_in_project_trimmed,$os_vol_gb_hours
  done < <(openstack volume list -f csv -c ID -c Name -c Status -c Size -c 'Attached to' --project $os_project_id | tail -n +2)
done
