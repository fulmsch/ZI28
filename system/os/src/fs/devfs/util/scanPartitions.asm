SECTION rom_code
PUBLIC devfs_scanPartitions

devfs_scanPartitions:
;; Check if a block device is partioned and add each partition to :DEV/.
;;
;; Open device, check if partitioned, read partition table
;; Copy existing entry, add number to name, add offset (driver agnostic?)
;;
;; Input:
;; : (hl) - name of base device

