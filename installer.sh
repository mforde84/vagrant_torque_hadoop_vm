#install redistributables if nec
cd redist;

#install vbox v5.2.18
which virtualbox || sudo sh VirtualBox-5.2.18-124319-Linux_amd64.run 
which virtualbox && { echo "virtual box successfully installed"; rm -rf VirtualBox-5.2.18-124319-Linux_amd64.run } || { echo "virtual box wasnt installed. exiting"; exit 1 }

#add dhcp nic for internal networking 
vboxmanage dhcpserver add --netname forde_sct_intnet --ip 192.168.10.1 --netmask 255.255.0.0 --lowerip 192.168.10.2 --upperip 192.168.10.255 --enable

#install vagrant for provisioning
unzip vagrant_2.1.5_linux_amd64.zip
sudo mv vagrant /usr/bin && { echo "vagrant successfully installed"; rm -rf vagrant_2.1.5_linux_amd64.zip } || { echo "vagrant wasnt installed. exiting"; exit 1 }

#extract payload
cd ..
tar zxvf payload.tar.gz
mkdir -p cn1 cn2 cn3 controller

#inject vagrant provisioning configs
mv payload/controller_vagrant.init controller/Vagrantfile
mv payload/cn1_vagrant.init cn1/Vagrantfile
mv payload/cn2_vagrant.init cn2/Vagrantfile
mv payload/cn3_vagrant.init cn3/Vagrantfile

#inject to controller
mv payload/torque-6.1.2.tar.gz controller/
cp payload/hwloc-1.9.1.tar.gz controller/
cp payload/centos.repo controller/
cd controller
tar zxvf torque-6.1.2.tar.gz
tar zxvf hwloc-1.9.1.tar.gz
rm -rf torque-6.1.2.tar.gz hwloc-1.9.1.tar.gz

#provision controller
vagrant up
vagrant snapshot save pbs_server_init

#inject to cn1
cd ..
cp payload/hwloc-1.9.1.tar.gz cn1/
cp controller/torque-6.1.2/torque-package-mom-linux-x86_64.sh cn1/
cp controller/torque-6.1.2/contrib/init.d/pbs_mom cn1/

#provision cn1
cd cn1
vagrant up
vagrant snapshot save pbs_mom_init

#inject to cn1
cd ..
cp payload/hwloc-1.9.1.tar.gz cn2/
cp controller/torque-6.1.2/torque-package-mom-linux-x86_64.sh cn2/
cp controller/torque-6.1.2/contrib/init.d/pbs_mom cn2/

#provision cn1
cd cn2
vagrant up
vagrant snapshot save pbs_mom_init

#inject to cn3
cd ..
cp payload/hwloc-1.9.1.tar.gz cn3/
cp controller/torque-6.1.2/torque-package-mom-linux-x86_64.sh cn3/
cp controller/torque-6.1.2/contrib/init.d/pbs_mom cn3/

#provision cn3
cd cn3
vagrant up
vagrant snapshot save pbs_mom_init
