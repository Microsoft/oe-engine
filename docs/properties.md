# Setting properties in the VM definition file

This document describes VM properties, configurable in the VM definition file

### VM name
Specifies VM name.

* Path: `properties/dvmProfiles[]/name`
* Value: string (follows the rules of underlying OS)

### OS type
Specifies the type of the OS.

* Path: `properties/vmProfiles[]/osType`
* Values:
    * `Linux`
    * `Windows`

The credentials and the image details of the OS deployment are specified in `properties/linuxProfile` and `properties/windowsProfile` respectively.

### OS disk type
Specifies OS disk characteristics.

* Path: `properties/vmProfiles[]/osDiskType`
* Values:
    * `Premium_LRS` - Premium SSD
    * `StandardSSD_LRS` - Standard SSD
    * `Standard_LRS` - Standard HDD

Note that VM sizes ending in `s` support Premium SSD storage. Those that do not end in `s`, such as `Standard_DC8_v2` only support Standard storage.

### VM compute power
Specifies VM compute characteristics

* Path: `properties/vmProfiles[]/vmSize`
* Values:
    * `Standard_DC2s`
    * `Standard_DC4s`
    * `Standard_DC1s_v2`
    * `Standard_DC2s_v2`
    * `Standard_DC4s_v2`
    * `Standard_DC8_v2`

Refer to the [VM sizes in Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/sizes) for more details.

### Data disks
Specifies sizes of attached data disks.

* Path: `properties/vmProfiles[]/diskSizesGB`
* Values: comma-separated array of disk sizes in GB

### Open ports
Specifies open ports in the Network Security Group (NSG)

* Path: `properties/vmProfiles[]/ports`
* Value: comma-separated array of port numbers

### VM Software
Indicates whether Open Enclave SDK and its dependencies should be installed or not.

* Path: `properties/vmProfiles[]/isVanilla`
* Values: boolean
    * `true` - a vanilla VM. Open Enclave SDK will not be installed
    * `false` - not a vanilla VM. Open Enclave SDK will be installed and verified

### DNS name
Indicates whether the VM has DNS name configured to `<vmName>.<region>.cloudapp.azure.com`

* Path: `properties/vmProfiles[]/hasDNSName`
* Values: boolean
    * `true` - the VM has DNS name
    * `false` - the VM doesn't have DNS name

### Linux credentials
If at least one of the VMs runs Linux, `linuxProfile` must be present and contain admin user name and password or public SSH key.
Multiple public keys are **supported**.
Setting both the password and the public key(s) is **not allowed**.

* Path: `properties/linuxProfile/adminUsername`
* Value: string

* Path: `properties/linuxProfile/adminPassword`
* Value: string

* Path: `properties/linuxProfile/sshPublicKeys[]/keyData`
* Value: public SSH key

The public SSH key(s) could also be set from the command line using `--ssh-public-key` argument.
```sh
oe-engine generate oe-vm.json --ssh-public-key .ssh/id_rsa1.pub --ssh-public-key .ssh/id_rsa2.pub
```

### Windows credentials
If at least one of the VMs runs Windows, `windowsProfile` must be present and contain admin user name and password.

* Path: `properties/windowsProfile/adminUsername`
* Value: string

* Path: `properties/windowsProfile/adminPassword`
* Value: string

### OS image
OS images can be either fetched from the Azure Image Gallery, or downloaded from the Internet.
The OS image settings equally apply to both Linux and Windows VMs.

To get the image from the Azure Image Gallery, one must provide image `publisher`, `offer`, `SKU`, and optionally the `version`.

* Path: `properties/{linux|windows}Profile/osImage/publisher`
* Value: string

* Path: `properties/{linux|windows}Profile/osImage/offer`
* Value: string

* Path: `properties/{linux|windows}Profile/osImage/sku`
* Value: string

* Path: `properties/{linux|windows}Profile/osImage/version`
* Value: string

Alternatively, you can specify image source URL.

* Path: `properties/{linux|windows}Profile/osImage/url`
* Value: string

Note that the _v2 version of the DC series VMs require a gen2 image of the OS. For example, in the case of Ubuntu, "18_04-lts-gen2".
