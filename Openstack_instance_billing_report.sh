#!/bin/bash
#
# Openstack billing report gnocchi instances dump to CSV
#

start_date=2021-02-01
end_date=2021-02-28

echo \"Project Name\",\"Project ID\",\"VM Name\",\"VM ID\",\"VM State\",\"CPU hours\",\"Memory MB hours\",\"VM Flavour\"

for os_project_id in $(openstack project list -f value -c ID)
do
  os_project_name=$(openstack project show -f value -c name $os_project_id)
  while IFS="," read -r os_vm_id_in_project os_vm_name_in_project os_vm_status_in_project os_vm_flavor_in_project
  do
    os_instace_cpu_hours=$(eval openstack metric measures show -r $os_vm_id_in_project vcpus --granularity 300 --resample 3600 -f value -c value --start $start_date --stop $end_date | paste -sd+ - | bc)
    os_instace_memory_hours=$(eval openstack metric measures show -r $os_vm_id_in_project memory --granularity 300 --resample 3600 -f value -c value --start $start_date --stop $end_date | paste -sd+ - | bc)
    echo \"$os_project_name\",\"$os_project_id\",$os_vm_name_in_project,$os_vm_id_in_project,$os_vm_status_in_project,$os_instace_cpu_hours,$os_instace_memory_hours,$os_vm_flavor_in_project
  done < <(openstack server list -f csv -c ID -c Name -c Status -c Flavor --project $os_project_id | tail -n +2)
done
