# devspaces-sshd-sandbox
Using SSH to connect to workspace

1. Import the editor definition

```bash
wget https://raw.githubusercontent.com/cgruver/devspaces-sshd-sandbox/refs/heads/externalize-js/base-sshd-editor-def/che-code-sshd-clg.yaml
oc login <cluster uri>
oc project <namespace where you deployed the CheCluster>
oc create configmap che-code-sshd-experimental-extjs --from-file=che-code-sshd-clg.yaml
oc label configmap che-code-sshd-experimental-extjs app.kubernetes.io/part-of=che.eclipse.org app.kubernetes.io/component=editor-definition
```

1. Create an SSH key pair, and upload it to your Dev Spaces profile

1. For workspaces running in OCP 4.20+ with nested containers enabled, use the following image as the base image for the workspace image:

   ```
   quay.io/cgruver0/che/sshd-workspace-base:userns
   ```

   For workspace without nested containers enabled use this image:

   ```
   quay.io/cgruver0/che/sshd-workspace-base:nouserns
   ```
