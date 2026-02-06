# Run the Quarkus Super Heros with Podman Compose


```bash
# If running VS Code in Browser
export API_BASE_URL=https://$(oc get route ${DEVWORKSPACE_ID}-dev-tools-8082-https-fights -o jsonpath={.spec.host})
```

```bash
podman compose -f ./compose/super-heroes-java17.yml up --remove-orphans
```

```bash
podman compose -f ./compose/super-heroes-java17.yml down
```