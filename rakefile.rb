device = "sdb"
image_name = "new-iso-image"
iso_name = "Fedora-15-x86_64-DVD.iso"

task :default => :create_iso

task :sdc do
  device = "sdc"
end

task :sdd do
  device = "sdd"
end

task :download_fedora do
  # http://download.fedoraproject.org/pub/fedora/linux/releases/18/Live/x86_64/Fedora-18-x86_64-Live-Desktop.iso
  sh "wget -c http://archive.fedoraproject.org/pub/fedora/linux/releases/15/Fedora/x86_64/iso/#{iso_name}"
end

task :clean do
  sh "rm -f #{image_name}.iso"
  sh "rm -rf ./image_new ./iso"
end

task :install_syslinux do
  sh "yum -y install syslinux"
end

task :prepare_iso_dirs do
  sh "mkdir -p ./iso"
  sh "sudo mount -ro loop #{iso_name} ./iso"
  sh "mkdir -p ./image_new"
end

desc "Create our own iso image with Fedora 15"
task :create_iso => [:install_syslinux, :clean, :download_fedora, :prepare_iso_dirs] do
  sh "cp -r ./iso/* ./image_new/"
  sh "rm -r ./image_new/isolinux"
  sh "cp -r ./isolinux ./image_new/"
  sh "cp ./iso/isolinux/initrd.img ./image_new/isolinux/"
  sh "cp ./iso/isolinux/vmlinuz ./image_new/isolinux/"
  sh "sudo umount ./iso"
  sh "mkisofs -J -r -V #{image_name} -hide-joliet-trans-tbl -hide-rr-moved -allow-leading-dots -o #{image_name}.iso -no-emul-boot -boot-load-size 4 -c isolinux/boot.catalog -b isolinux/isolinux.bin -boot-info-table -l image_new"
  sh "isohybrid #{image_name}.iso"
end

desc "Create our own iso image with Fedora 15 (netinstall)"
task :create_iso_netinstall => [:install_syslinux, :clean, :download_fedora, :prepare_iso_dirs] do
  sh "cp -r ./isolinux ./image_new/"
  sh "cp ./iso/isolinux/initrd.img ./image_new/isolinux/"
  sh "cp ./iso/isolinux/vmlinuz ./image_new/isolinux/"
  sh "sudo umount ./iso"
  sh "mkisofs -J -r -V #{image_name} -hide-joliet-trans-tbl -hide-rr-moved -allow-leading-dots -o #{image_name}-netinstall.iso -no-emul-boot -boot-load-size 4 -c isolinux/boot.catalog -b isolinux/isolinux.bin -boot-info-table -l image_new"
  sh "isohybrid #{image_name}-netinstall.iso"
end

task :write_iso do
  sh "dd if=#{image_name}.iso of=/dev/#{device} bs=1M"
end

task :write_iso_mac do
  sh "diskutil list" 
  # sh "hdiutil convert -format UDRW -o #{image_name} #{image_name}.iso"
  sh "diskutil unmountDisk /dev/disk1"
  sh "sudo dd if=#{image_name}.iso of=/dev/rdisk1 bs=1m"
  sh "sudo diskutil eject /dev/disk1"
end
