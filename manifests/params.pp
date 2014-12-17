# == Class: kdump::params
#
# The kdump configuration settings.
#
# === Variables
#
# === Authors
#
# Trey Dockendorf <treydock@gmail.com>
#
# === Copyright
#
# Copyright 2013 Trey Dockendorf
#
class kdump::params {

  case $::osfamily {
    'RedHat': {
      $package_name       = 'kexec-tools'
      $service_name       = 'kdump'
      $service_hasstatus  = true
      $service_hasrestart = true
      $config_path        = '/etc/kdump.conf'
      $sysconfig_file     = '/etc/sysconfig/kdump'

      $config_defaults = {
        'path'              => '/var/crash',
        'core_collector'    => 'makedumpfile -c --message-level 1 -d 31',
        'raw'               => 'UNSET',
        'nfs'               => 'UNSET',
        'nfs4'              => 'UNSET',
        'ssh'               => 'UNSET',
        'ext4'              => 'UNSET',
        'ext3'              => 'UNSET',
        'ext2'              => 'UNSET',
        'minix'             => 'UNSET',
        'btrfs'             => 'UNSET',
        'xfs'               => 'UNSET',
        'link_delay'        => 'UNSET',
        'kdump_post'        => 'UNSET',
        'kdump_pre'         => 'UNSET',
        'extra_bins'        => 'UNSET',
        'extra_modules'     => 'UNSET',
        'options'           => 'UNSET',
        'blacklist'         => 'UNSET',
        'sshkey'            => 'UNSET',
        'default'           => 'UNSET',
        'debug_mem_level'   => 'UNSET',
        'force_rebuild'     => 'UNSET',
      }

      if versioncmp($::operatingsystemmajrelease, '7') >= 0 {
        $kernel_parameter_provider = 'grub2'
      } else {
        $kernel_parameter_provider = 'grub'
      }

      $kdump_kernelver   = ''
      $kdump_commandline = ''
      $kdump_bootdir     = '/boot'
      $kdump_img         = 'vmlinuz'
      $kdump_img_ext     =  ''
      case $::lsbmajdistrelease {
        '5': {
          $kexec_args               = ' --args-linux'
          $kdump_commandline_append = 'irqpoll maxcpus=1'
          $mkdumprd_args            = undef
        }
        '6': {
          $kexec_args = ''
          case $::architecture {
            'i386':   { $kdump_commandline_append = 'irqpoll nr_cpus=1 reset_devices cgroup_disable=memory' }
            'x86_64': { $kdump_commandline_append = 'irqpoll nr_cpus=1 reset_devices cgroup_disable=memory mce=off' }
            default:  { fail("Unsupported architecture ${::architecture}, module ${module_name} only support architecture i386 and x86_64") }
          }
          $mkdumprd_args = $::virtual ? {
            'vmware' => '--builtin=vsock --builtin=vmci',
            default  => '',
          }
        }
        default: {
          fail("Unsupported Redhat Release ${::lsbmajdistrelease},  module ${module_name} only support lsbmajdistrelease 5 and 6")
        }
      }
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily}, module ${module_name} only support osfamily RedHat")
    }
  }
}
