# Reproducer for selinux issue


```bash
cat << EOF | oc apply -f -
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  name: nested-podman-scc
priority: null
allowPrivilegeEscalation: true
allowedCapabilities:
- SETUID
- SETGID
fsGroup:
  type: MustRunAs
  ranges:
  - min: 1000
    max: 65534
runAsUser:
  type: MustRunAs
  uid: 1000
seLinuxContext:
  type: MustRunAs
  seLinuxOptions:
    type: container_engine_t
supplementalGroups:
  type: MustRunAs
  ranges:
  - min: 1000
    max: 65534
userNamespaceLevel: RequirePodLevel
EOF
```

```bash
oc new-project sshd-test
ssh-keygen -q -N "" -t ed25519 -f ./ssh_ed25519
oc create secret generic ssh-key --from-file=./ssh_ed25519.pub
```

```bash
cat << EOF | oc apply -f -
kind: Pod
apiVersion: v1
metadata:
  name: sshd-in-pod
  namespace: sshd-test
  annotations:
    io.kubernetes.cri-o.Devices: '/dev/fuse,/dev/net/tun'
    openshift.io/scc: nested-podman-scc
spec:
  hostUsers: false
  restartPolicy: Always
  containers:
    - resources:
        limits:
          cpu: "1"
          memory: 2Gi
        requests:
          cpu: 100m
          memory: 256Mi
      name: sshd-test
      securityContext:
        capabilities:
          add:
            - SETGID
            - SETUID
          drop:
            - ALL
        runAsUser: 1000
        runAsNonRoot: true
        readOnlyRootFilesystem: false
        allowPrivilegeEscalation: true
        procMount: Unmasked
      imagePullPolicy: Always
      volumeMounts:
        - name: ssh-key
          readOnly: true
          mountPath: /etc/ssh/dwo_ssh_key.pub
          subPath: ssh_ed25519.pub
      image: 'quay.io/cgruver0/che/sshd-workspace-base:userns'
  volumes:
    - name: ssh-key
      secret:
        secretName: ssh-key
        defaultMode: 416
EOF
```

```bash
oc port-forward sshd-in-pod 2022:2022
```

```bash
ssh -i ./ssh_ed25519 -p 2022 user@localhost
```

```bash
ausearch -m AVC -ts recent
```

```bash
time->Thu Nov  6 14:11:37 2025
type=PROCTITLE msg=audit(1762438297.398:601): proctitle=737368643A205B61636365707465645D
type=SYSCALL msg=audit(1762438297.398:601): arch=c000003e syscall=44 success=no exit=-13 a0=8 a1=7ffffa374f50 a2=f0 a3=0 items=0 ppid=121672 pid=121673 auid=4294967295 uid=1736115176 gid=1736115176 euid=1736115176 suid=1736115176 fsuid=1736115176 egid=1736115176 sgid=1736115176 fsgid=1736115176 tty=(none) ses=4294967295 comm="sshd" exe="/usr/sbin/sshd" subj=system_u:system_r:container_engine_t:s0:c17,c28 key=(null)
type=AVC msg=audit(1762438297.398:601): avc:  denied  { nlmsg_relay } for  pid=121673 comm="sshd" scontext=system_u:system_r:container_engine_t:s0:c17,c28 tcontext=system_u:system_r:container_engine_t:s0:c17,c28 tclass=netlink_audit_socket permissive=0
----
time->Thu Nov  6 14:11:37 2025
type=PROCTITLE msg=audit(1762438297.405:602): proctitle=737368643A205B61636365707465645D
type=SYSCALL msg=audit(1762438297.405:602): arch=c000003e syscall=44 success=no exit=-13 a0=5 a1=7ffffa374e80 a2=f8 a3=0 items=0 ppid=117151 pid=121672 auid=4294967295 uid=1736115176 gid=1736115176 euid=1736115176 suid=1736115176 fsuid=1736115176 egid=1736115176 sgid=1736115176 fsgid=1736115176 tty=(none) ses=4294967295 comm="sshd" exe="/usr/sbin/sshd" subj=system_u:system_r:container_engine_t:s0:c17,c28 key=(null)
type=AVC msg=audit(1762438297.405:602): avc:  denied  { nlmsg_relay } for  pid=121672 comm="sshd" scontext=system_u:system_r:container_engine_t:s0:c17,c28 tcontext=system_u:system_r:container_engine_t:s0:c17,c28 tclass=netlink_audit_socket permissive=0
----
time->Thu Nov  6 14:11:37 2025
type=PROCTITLE msg=audit(1762438297.405:603): proctitle=737368643A205B61636365707465645D
type=SYSCALL msg=audit(1762438297.405:603): arch=c000003e syscall=44 success=no exit=-13 a0=5 a1=7ffffa374be0 a2=f0 a3=0 items=0 ppid=117151 pid=121672 auid=4294967295 uid=1736115176 gid=1736115176 euid=1736115176 suid=1736115176 fsuid=1736115176 egid=1736115176 sgid=1736115176 fsgid=1736115176 tty=(none) ses=4294967295 comm="sshd" exe="/usr/sbin/sshd" subj=system_u:system_r:container_engine_t:s0:c17,c28 key=(null)
type=AVC msg=audit(1762438297.405:603): avc:  denied  { nlmsg_relay } for  pid=121672 comm="sshd" scontext=system_u:system_r:container_engine_t:s0:c17,c28 tcontext=system_u:system_r:container_engine_t:s0:c17,c28 tclass=netlink_audit_socket permissive=0
----
time->Thu Nov  6 14:11:37 2025
type=PROCTITLE msg=audit(1762438297.405:604): proctitle=737368643A205B61636365707465645D
type=SYSCALL msg=audit(1762438297.405:604): arch=c000003e syscall=44 success=no exit=-13 a0=5 a1=7ffffa374c70 a2=6c a3=0 items=0 ppid=117151 pid=121672 auid=4294967295 uid=1736115176 gid=1736115176 euid=1736115176 suid=1736115176 fsuid=1736115176 egid=1736115176 sgid=1736115176 fsgid=1736115176 tty=(none) ses=4294967295 comm="sshd" exe="/usr/sbin/sshd" subj=system_u:system_r:container_engine_t:s0:c17,c28 key=(null)
type=AVC msg=audit(1762438297.405:604): avc:  denied  { nlmsg_relay } for  pid=121672 comm="sshd" scontext=system_u:system_r:container_engine_t:s0:c17,c28 tcontext=system_u:system_r:container_engine_t:s0:c17,c28 tclass=netlink_audit_socket permissive=0
```

```bash
cat << EOF > sshd_fix.te
module sshd_fix 1.0;
require {
	type container_engine_t;
	class netlink_audit_socket nlmsg_relay;
}

#============= container_engine_t ==============
allow container_engine_t self:netlink_audit_socket nlmsg_relay;
EOF

checkmodule -M -m -o sshd_fix.mod sshd_fix.te && semodule_package -o sshd_fix.pp -m sshd_fix.mod && semodule -i sshd_fix.pp
```
