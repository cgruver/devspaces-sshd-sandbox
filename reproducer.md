kind: Pod
apiVersion: v1
metadata:
  name: sshd-in-pod
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
      name: dev-tools
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
          mountPath: /etc/ssh/ssh_config
          subPath: ssh_config
        - name: ssh-key
          readOnly: true
          mountPath: /etc/ssh/dwo_ssh_key
          subPath: dwo_ssh_key
        - name: ssh-key
          readOnly: true
          mountPath: /etc/ssh/dwo_ssh_key.pub
          subPath: dwo_ssh_key.pub
      image: 'quay.io/cgruver0/che/sshd-workspace-base:userns'
  volumes:
    - name: ssh-key
      secret:
        secretName: ssh-key
        defaultMode: 416


