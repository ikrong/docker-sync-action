## Sync Docker Images

This is a github action will help you sync images between registries.

## Help

1. Fork This repo or create your own repo.

2. Create workflow yaml in .github/workflows directionary.

```yaml
name: Sync Docker Images
on: 
  workflow_dispatch:
    inputs:
      source:
        description: 'Source repository'     
        required: true
        default: 'docker.io'
      destination:
        description: 'Destination repository'
        required: true
        default: 'docker.io'
      sync:
        description: 'Repos for Sync'
        required: false
        default: ''
      copy:
        description: 'Repos for Copy'
        required: false
        default: ''

jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
    - name: Sync Docker Images
      uses: ikrong/docker-sync-action@main
      with:
        source: ${{ github.event.inputs.source }}
        source-credential: ${{ secrets.DOCKER_SOURCE_CREDENTIAL }}
        destination: ${{ github.event.inputs.destination }}
        destination-credential: ${{ secrets.DOCKER_DESTINATION_CREDENTIAL }}
        sync: ${{ github.event.inputs.sync }}
        copy: ${{ github.event.inputs.copy }}
```

3. Setting source and destination registry username and password.

4. Click run workflow and fill the form in Actions tab.