#  docker build -t bfb_runtime_mariner -f Dockerfile .
FROM --platform=linux/arm64 cblmariner.azurecr.io/base/core:1.0
ADD qemu-aarch64-static /usr/bin/

WORKDIR /root/workspace
ADD install.sh .
ADD create_bfb .
ADD update.cap .

ENV kernel=5.10.74.1-1.cm1
ENV RUN_FW_UPDATER=no

RUN yum install -y util-linux dnf-utils netplan openssh-server iproute which git selinux-policy-devel tcp_wrappers-devel diffutils file procps-ng patch rpm-build kernel-$kernel kernel-devel-$kernel kernel-headers-$kernel python-netifaces libreswan python3-devel python3-idle python3-test python3-tkinter python3-Cython efibootmgr efivar grub2 grub2-efi grub2-efi-unsigned shim-unsigned-aarch64 device-mapper-persistent-data lvm2 acpid perf popt-devel bc flex bison edac-utils lm_sensors lm_sensors-sensord re2c ninja-build meson cryptsetup rasdaemon pciutils-devel watchdog python3-sphinx python3-six kexec-tools jq dbus libgomp iana-etc libgomp-devel libgcc-devel libgcc-atomic libmpc binutils libsepol-devel iptables glibc-devel gcc tcl-devel automake libmnl autoconf tcl libnl3-devel openssl-devel libstdc++-devel binutils-devel libselinux-devel libnl3 libdb-devel make libmnl-devel iptables-devel lsof desktop-file-utils doxygen cmake cmake3 libcap-ng-devel systemd-devel ncurses-devel kmod

RUN depmod -a 5.10.74.1-1.cm1
RUN yum-config-manager --nogpgcheck --add-repo https://linux.mellanox.com/public/repo/doca/1.2.0/mariner1.0/aarch64/
RUN sed -i -e "s/linux.mellanox.com_public_repo_doca_1.2.0_mariner1.0_aarch64_/doca/" /etc/yum.repos.d/linux.mellanox.com_public_repo_doca_1.2.0_mariner1.0_aarch64_.repo
RUN yum-config-manager --save --setopt=doca.sslverify=0 doca
RUN yum-config-manager --save --setopt=doca.gpgcheck=0 doca
RUN yum-config-manager --dump doca

RUN yum install -y gpio-mlxbf ibacm ibutils2 infiniband-diags infiniband-diags-compat ipmb-dev-int ipmb-host kernel-mft knem knem-modules libibumad libibverbs libibverbs-utils libpka librdmacm librdmacm-utils libxpmem libxpmem-devel mft mft-oem mlnx-ethtool mlnx-fw-updater mlnx-iproute2 mlnx-libsnap mlnx-nvme mlnx-tools mlx-bootctl mlx-regex mlx-trio mlxbf-bootctl mlxbf-bootimages mlxbf-livefish mlxbf-pmc mstflint ofed-scripts opensm opensm-devel opensm-libs opensm-static perftest rdma-core rdma-core-devel srp_daemon tmfifo ucx ucx-cma ucx-devel ucx-ib ucx-knem ucx-rdmacm ucx-xpmem xpmem xpmem-modules

RUN wget --no-check-certificate --no-verbose $(repoquery --nogpgcheck --location mlnx-ofa_kernel)
RUN wget --no-check-certificate --no-verbose $(repoquery --nogpgcheck --location mlnx-ofa_kernel-devel)
RUN wget --no-check-certificate --no-verbose $(repoquery --nogpgcheck --location mlnx-ofa_kernel-modules)
RUN wget --no-check-certificate --no-verbose $(repoquery --nogpgcheck --location mlnx-ofa_kernel-source)
RUN rpm -iv --nodeps mlnx-ofa_kernel*rpm

RUN wget --no-check-certificate --no-verbose $(repoquery --nogpgcheck --location openvswitch)
RUN wget --no-check-certificate --no-verbose $(repoquery --nogpgcheck --location openvswitch-devel)
RUN wget --no-check-certificate --no-verbose $(repoquery --nogpgcheck --location python3-openvswitch)
RUN rpm -Uv --nodeps *openvswitch*rpm

RUN wget --no-check-certificate --no-verbose $(repoquery --nogpgcheck --location mlxbf-bfscripts)
RUN rpm -iv --nodeps mlxbf-bfscripts*rpm

RUN wget --no-check-certificate --no-verbose $(repoquery --nogpgcheck --location bf-release)
RUN rpm -iv --nodeps bf-release*rpm

RUN /bin/rm -f *rpm

CMD ["/root/workspace/create_bfb", "-k", "5.10.74.1-1.cm1"]
