#
# Copyright (C) 2010 OpenWrt.org
#

PART_NAME=firmware
REQUIRE_IMAGE_METADATA=1

RAMFS_COPY_BIN='fw_printenv fw_setenv'
RAMFS_COPY_DATA='/etc/fw_env.config /var/lock/fw_printenv.lock'

platform_check_image() {
	return 0
}

platform_do_upgrade() {
	local board=$(board_name)

	case "$board" in
	alfa-network,quad-e4g)
		[ "$(fw_printenv -n dual_image 2>/dev/null)" = "1" ] &&\
		[ -n "$(find_mtd_part backup)" ] && {
			PART_NAME=backup
			if [ "$(fw_printenv -n bootactive 2>/dev/null)" = "1" ]; then
				fw_setenv bootactive 2 || exit 1
			else
				fw_setenv bootactive 1 || exit 1
			fi
		}
		;;
	mikrotik,rb750gr3|\
	mikrotik,rbm11g|\
	mikrotik,rbm33g)
		[ -z "$(rootfs_type)" ] && mtd erase firmware
		;;
	asus,rt-ac65p|\
	asus,rt-ac85p)
		echo "Backing up firmware"
		dd if=/dev/mtd4 bs=1024 count=4096  > /tmp/backup_firmware.bin
		dd if=/dev/mtd5 bs=1024 count=52224 >> /tmp/backup_firmware.bin
		mtd -e firmware2 write /tmp/backup_firmware.bin firmware2
		;;
	esac

	case "$board" in
	asus,rt-ac65p|\
	asus,rt-ac85p|\
	hiwifi,hc5962|\
	netgear,r6220|\
	netgear,r6260|\
	netgear,r6350|\
	netgear,r6800|\
	netgear,r6850|\
	netis,wf2881|\
	xiaomi,mir3g|\
	xiaomi,mir3p)
		nand_do_upgrade "$1"
		;;
	ubiquiti,edgerouterx|\
	ubiquiti,edgerouterx-sfp)
		platform_upgrade_ubnt_erx "$1"
		;;
	*)
		default_do_upgrade "$1"
		;;
	esac
}
