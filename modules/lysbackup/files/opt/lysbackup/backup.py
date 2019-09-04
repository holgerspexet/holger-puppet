#!/usr/bin/python3 -u
import subprocess
import os
import time
import sys

if __name__ == '__main__':
        start = time.time()
        print('Starting backup at '+time.strftime("%Y-%m-%dT%H:%M:%S", time.localtime(start)))

        if len(sys.argv) < 1:
                sys.exit("Provide a user on the remote")

        user = sys.argv[1]
        host = os.uname().nodename
        network_location = user + "@diskmaskin:~/backup"

        repo = user + "@diskmaskin:~/backup::"+host+"-{now}"

        ## directory and repo should exist and must be initialized beforehand
        subprocess.run(["borg", "create", "--compression", "lz4", \
                        "--exclude-caches", "--exclude-from", "/opt/lysbackup/exclude.txt", \
                        "--exclude-if-present", ".nobackup", repo, "/"])
        subprocess.run(["borg", "prune", \
                        "--keep-hourly", "24", \
                        "--keep-daily", "7", \
                        "--keep-weekly", "4", \
                        "--keep-monthly", "3", network_location])


        diff = time.time() - start
        print('Finished backup in {0:0>10.1f} seconds.'.format(diff))

        with open('/var/lib/prometheus-dropzone/last_backup_done_at', 'w') as f:
            f.write('last_backup_done_at.prom {}\n'.format(time.time()))
        with open('/var/lib/prometheus-dropzone/backup_duration', 'w') as f:
            f.write('last_backup_duration.prom {}\n'.format(diff))
